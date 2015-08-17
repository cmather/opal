require 'corelib/numeric'

class Number < Numeric
  Opal.bridge(self, `Number`)

  `Number.prototype.$$is_number = true`

  def coerce(other)
    %x{
      if (!#{other.is_a? Numeric}) {
        #{raise TypeError, "can't convert #{other.class} into Float"};
      }

      if (other.$$is_number) {
        return [self, other];
      }
      else if (#{self.respond_to?(:to_f)} && #{other.respond_to?(:to_f)}) {
        return [self.$to_f(), other.$to_f()];
      }
      else {
        #{raise TypeError, "can't convert #{other.class} into Float"};
      }
    }
  end

  def __id__
    `(self * 2) + 1`
  end

  alias object_id __id__

  def +(other)
    %x{
      if (other.$$is_number) {
        return self + other;
      }
      else {
        return #{__coerced__ :+, other};
      }
    }
  end

  def -(other)
    %x{
      if (other.$$is_number) {
        return self - other;
      }
      else {
        return #{__coerced__ :-, other};
      }
    }
  end

  def *(other)
    %x{
      if (other.$$is_number) {
        return self * other;
      }
      else {
        return #{__coerced__ :*, other};
      }
    }
  end

  def /(other)
    %x{
      if (other.$$is_number) {
        return self / other;
      }
      else {
        return #{__coerced__ :/, other};
      }
    }
  end

  alias fdiv /

  def %(other)
    %x{
      if (other.$$is_number) {
        if (other < 0 || self < 0) {
          return (self % other + other) % other;
        }
        else {
          return self % other;
        }
      }
      else {
        return #{__coerced__ :%, other};
      }
    }
  end

  def &(other)
    %x{
      if (other.$$is_number) {
        return self & other;
      }
      else {
        return #{__coerced__ :&, other};
      }
    }
  end

  def |(other)
    %x{
      if (other.$$is_number) {
        return self | other;
      }
      else {
        return #{__coerced__ :|, other};
      }
    }
  end

  def ^(other)
    %x{
      if (other.$$is_number) {
        return self ^ other;
      }
      else {
        return #{__coerced__ :^, other};
      }
    }
  end

  def <(other)
    %x{
      if (other.$$is_number) {
        return self < other;
      }
      else {
        return #{__coerced__ :<, other};
      }
    }
  end

  def <=(other)
    %x{
      if (other.$$is_number) {
        return self <= other;
      }
      else {
        return #{__coerced__ :<=, other};
      }
    }
  end

  def >(other)
    %x{
      if (other.$$is_number) {
        return self > other;
      }
      else {
        return #{__coerced__ :>, other};
      }
    }
  end

  def >=(other)
    %x{
      if (other.$$is_number) {
        return self >= other;
      }
      else {
        return #{__coerced__ :>=, other};
      }
    }
  end

  def <=>(other)
    %x{
      if (other.$$is_number) {
        return self > other ? 1 : (self < other ? -1 : 0);
      }
      else {
        return #{__coerced__ :<=>, other};
      }
    }
  rescue ArgumentError
    nil
  end

  def <<(count)
    count = Opal.coerce_to! count, Integer, :to_int

    `#{count} > 0 ? self << #{count} : self >> -#{count}`
  end

  def >>(count)
    count = Opal.coerce_to! count, Integer, :to_int

    `#{count} > 0 ? self >> #{count} : self << -#{count}`
  end

  def [](bit)
    bit = Opal.coerce_to! bit, Integer, :to_int
    min = -(2**30)
    max =  (2**30) - 1

    `(#{bit} < #{min} || #{bit} > #{max}) ? 0 : (self >> #{bit}) % 2`
  end

  def +@
    `+self`
  end

  def -@
    `-self`
  end

  def ~
    `~self`
  end

  def **(other)
    if Integer === other
      if !(Integer === self) || other > 0
        `Math.pow(self, other)`
      else
        Rational.new(self, 1) ** other
      end
    elsif Float === other && self < 0
      Complex.new(self, 0) ** other
    elsif `other.$$is_number != null`
      `Math.pow(self, other)`
    else
      __coerced__ :**, other
    end
  end

  def ==(other)
    %x{
      if (other.$$is_number) {
        return self == Number(other);
      }
      else if (#{other.respond_to? :==}) {
        return #{other == self};
      }
      else {
        return false;
      }
    }
  end

  def abs
    `Math.abs(self)`
  end

  def abs2
    `Math.abs(self * self)`
  end

  def angle
    `self < 0 ? Math.PI : 0`
  end

  alias arg angle

  def ceil
    `Math.ceil(self)`
  end

  def chr(encoding = undefined)
    `String.fromCharCode(self)`
  end

  def downto(stop, &block)
    return enum_for(:downto, stop){
      raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless Numeric === stop
      stop > self ? 0 : self - stop + 1
    } unless block_given?

    %x{
      if (!stop.$$is_number) {
        #{raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed"}
      }
      for (var i = self; i >= stop; i--) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  alias eql? ==

  def equal?(other)
    self == other || `isNaN(self) && isNaN(other)`
  end

  def even?
    `self % 2 === 0`
  end

  def floor
    `Math.floor(self)`
  end

  def gcd(other)
    unless Integer === other
      raise TypeError, 'not an integer'
    end

    %x{
      var min = Math.abs(self),
          max = Math.abs(other);

      while (min > 0) {
        var tmp = min;

        min = max % min;
        max = tmp;
      }

      return max;
    }
  end

  def gcdlcm(other)
    [gcd, lcm]
  end

  def hash
    `'Numeric:'+self.toString()`
  end

  def integer?
    `self % 1 === 0`
  end

  def is_a?(klass)
    return true if klass == Fixnum && Integer === self
    return true if klass == Integer && Integer === self
    return true if klass == Float && Float === self

    super
  end

  alias kind_of? is_a?

  def instance_of?(klass)
    return true if klass == Fixnum && Integer === self
    return true if klass == Integer && Integer === self
    return true if klass == Float && Float === self

    super
  end

  def lcm(other)
    unless Integer === other
      raise TypeError, 'not an integer'
    end

    %x{
      if (self == 0 || other == 0) {
        return 0;
      }
      else {
        return Math.abs(self * other / #{gcd(other)});
      }
    }
  end

  alias magnitude abs

  alias modulo %

  def next
    `self + 1`
  end

  def nonzero?
    `self == 0 ? nil : self`
  end

  def odd?
    `self % 2 !== 0`
  end

  def ord
    self
  end

  def pred
    `self - 1`
  end

  def round(ndigits=0)
    %x{
      var scale = Math.pow(10, ndigits);
      return Math.round(self * scale) / scale;
    }
  end

  def step(limit, step = 1, &block)
    return enum_for :step, limit, step unless block

    raise ArgumentError, 'step cannot be 0' if `step == 0`

    %x{
      var value = self;

      if (limit === Infinity || limit === -Infinity) {
        block(value);
        return self;
      }

      if (step > 0) {
        while (value <= limit) {
          block(value);
          value += step;
        }
      }
      else {
        while (value >= limit) {
          block(value);
          value += step;
        }
      }
    }

    self
  end

  alias succ next

  def times(&block)
    return enum_for :times unless block

    %x{
      for (var i = 0; i < self; i++) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def to_f
    self
  end

  def to_i
    `parseInt(self, 10)`
  end

  alias to_int to_i

  def to_r
    if Integer === self
      Rational.new(self, 1)
    else
      f, e  = Math.frexp(self)
      f     = Math.ldexp(f, Float::MANT_DIG).to_i
      e    -= Float::MANT_DIG

      (f * (Float::RADIX ** e)).to_r
    end
  end

  def to_s(base = 10)
    if base < 2 || base > 36
      raise ArgumentError, 'base must be between 2 and 36'
    end

    `self.toString(base)`
  end

  alias truncate to_i

  alias inspect to_s

  def divmod(rhs)
    q = (self / rhs).floor
    r = self % rhs

    [q, r]
  end

  def upto(stop, &block)
    return enum_for(:upto, stop){
      raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless Numeric === stop
      stop < self ? 0 : stop - self + 1
    } unless block_given?

    %x{
      if (!stop.$$is_number) {
        #{raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed"}
      }
      for (var i = self; i <= stop; i++) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def zero?
    `self == 0`
  end

  # Since bitwise operations are 32 bit, declare it to be so.
  def size
    4
  end

  def nan?
    `isNaN(self)`
  end

  def finite?
    `self != Infinity && self != -Infinity && !isNaN(self)`
  end

  def infinite?
    %x{
      if (self == Infinity) {
        return +1;
      }
      else if (self == -Infinity) {
        return -1;
      }
      else {
        return nil;
      }
    }
  end

  def positive?
    `1 / self > 0`
  end

  def negative?
    `1 / self < 0`
  end
end

Fixnum = Number

class Integer < Numeric
  def self.===(other)
    %x{
      if (!other.$$is_number) {
        return false;
      }

      return (other % 1) === 0;
    }
  end
end

class Float < Numeric
  def self.===(other)
    `!!other.$$is_number`
  end

  INFINITY = `Infinity`
  MAX      = `Number.MAX_VALUE`
  MIN      = `Number.MIN_VALUE`
  NAN      = `NaN`

  MANT_DIG = 53
  RADIX    = 2

  if defined?(`Number.EPSILON`)
    EPSILON = `Number.EPSILON`
  else
    EPSILON = `2.2204460492503130808472633361816E-16`
  end
end