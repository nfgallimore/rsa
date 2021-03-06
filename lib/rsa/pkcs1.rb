module RSA
  ##
  # Support for the PKCS #1 (aka RFC 3447) padding schemes.
  #
  # @see http://en.wikipedia.org/wiki/PKCS1
  # @see http://tools.ietf.org/html/rfc3447
  # @see http://www.rsa.com/rsalabs/node.asp?id=2125
  module PKCS1
    ##
    # Converts a nonnegative integer into an octet string of a specified
    # length.
    #
    # This is the PKCS #1 I2OSP (Integer-to-Octet-String) primitive.
    # Refer to PKCS #1 v2.1 pp. 8-9, section 4.1.
    #
    # @example
    #   RSA::PKCS1.i2osp(9_202_000, 2)    #=> ArgumentError: integer too large
    #   RSA::PKCS1.i2osp(9_202_000, 3)    #=> "\x8C\x69\x50"
    #   RSA::PKCS1.i2osp(9_202_000, 4)    #=> "\x00\x8C\x69\x50"
    #
    # @param  [Integer] x   nonnegative integer to be converted
    # @param  [Integer] len intended length of the resulting octet string
    # @return [String] octet string of length `len`
    # @see    http://tools.ietf.org/html/rfc3447#section-4.1
    # @raise  [ArgumentError] if `n` is greater than 256^len
    def self.i2osp(x, len = nil)
      raise ArgumentError, "integer too large" if len && x >= 256**len

      StringIO.open do |buffer|
        while x > 0
          b = (x & 0xFF).chr
          x >>= 8
          buffer << b
        end
        s = buffer.string
        s.force_encoding(Encoding::BINARY) if s.respond_to?(:force_encoding)
        s.reverse!
        s = len ? s.rjust(len, "\0") : s
      end
    end

    ##
    # Converts an octet string into a nonnegative integer.
    #
    # This is the PKCS #1 OS2IP (Octet-String-to-Integer) primitive.
    # Refer to PKCS #1 v2.1 p. 9, section 4.2.
    #
    # @example
    #   RSA::PKCS1.os2ip("\x8C\x69\x50")  #=> 9_202_000
    #
    # @param  [String] x octet string to be converted
    # @return [Integer] nonnegative integer
    # @see    http://tools.ietf.org/html/rfc3447#section-4.2
    def self.os2ip(x)
      x.bytes.inject(0) { |n, b| (n << 8) + b }
    end

    ##
    # Produces a ciphertext representative from a message representative
    # under the control of a public key.
    #
    # This is the PKCS #1 RSAEP encryption primitive.
    # Refer to PKCS #1 v2.1 p. 10, section 5.1.1.
    #
    # @param  [Key, #to_a] k RSA public key (`n`, `e`)
    # @param  [Integer] m message representative, an integer between 0 and `n` - 1
    # @return [Integer] ciphertext representative, an integer between 0 and `n` - 1
    # @raise  [ArgumentError] if `m` is out of range
    # @see    http://tools.ietf.org/html/rfc3447#section-5.1.1
    def self.rsaep(k, m)
      n, e = k.to_a
      raise ArgumentError, "message representative out of range" unless m >= 0 && m < n
      c = Math.modpow(m, e, n)
    end

    ##
    # Recovers the message representative from a ciphertext representative
    # under the control of a private key.
    #
    # This is the PKCS #1 RSADP decryption primitive.
    # Refer to PKCS #1 v2.1 pp. 10-11, section 5.1.2.
    #
    # @param  [Key, #to_a] k RSA private key (`n`, `d`)
    # @param  [Integer] c ciphertext representative, an integer between 0 and `n` - 1
    # @return [Integer] message representative, an integer between 0 and `n` - 1
    # @raise  [ArgumentError] if `c` is out of range
    # @see    http://tools.ietf.org/html/rfc3447#section-5.1.2
    def self.rsadp(k, c)
      n, d = k.to_a
      raise ArgumentError, "ciphertext representative out of range" unless c >= 0 && c < n
      m = Math.modpow(c, d, n)
    end

    ##
    # Produces a signature representative from a message representative
    # under the control of a private key.
    #
    # This is the PKCS #1 RSASP1 signature primitive.
    # Refer to PKCS #1 v2.1 pp. 12-13, section 5.2.1.
    #
    # @param  [Key, #to_a] k RSA private key (`n`, `d`)
    # @param  [Integer] m message representative, an integer between 0 and `n` - 1
    # @return [Integer] signature representative, an integer between 0 and `n` - 1
    # @raise  [ArgumentError] if `m` is out of range
    # @see    http://tools.ietf.org/html/rfc3447#section-5.2.1
    def self.rsasp1(k, m)
      n, d = k.to_a
      raise ArgumentError, "message representative out of range" unless m >= 0 && m < n
      s = Math.modpow(m, d, n)
    end

    ##
    # Recovers the message representative from a signature representative
    # under the control of a public key.
    #
    # This is the PKCS #1 RSAVP1 verification primitive.
    # Refer to PKCS #1 v2.1 p. 13, section 5.2.2.
    #
    # @param  [Key, #to_a] k RSA public key (`n`, `e`)
    # @param  [Integer] s signature representative, an integer between 0 and `n` - 1
    # @return [Integer] message representative, an integer between 0 and `n` - 1
    # @raise  [ArgumentError] if `s` is out of range
    # @see    http://tools.ietf.org/html/rfc3447#section-5.2.2
    def self.rsavp1(k, s)
      n, e = k.to_a
      raise ArgumentError, "signature representative out of range" unless s >= 0 && s < n
      m = Math.modpow(s, e, n)
    end
  end # module PKCS1
end # module RSA
