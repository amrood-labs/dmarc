require 'dmarc/dmarc'
require 'dmarc/parser'
require 'dmarc/validator'
require 'dmarc/error'

require 'resolv'

module DMARC
  class Record

    # `p` field.
    # 
    # @return [:none, :quarantine, :reject]
    attr_accessor :p

    # `rua` field.
    #
    # @return [Array<Uri>]
    attr_accessor :rua

    # `rua` field.
    #
    # @return [Array<Uri>]
    attr_accessor :ruf

    # `sp` field.
    # 
    # @return [:none, :quarantine, :reject]
    attr_accessor :sp

    # `v` field.
    #
    # @return [:DMARC1]
    attr_accessor :v

    # `v` field.
    #
    # @return [Array<Error>]
    attr_accessor :errors

    #
    # Initializes the record.
    #
    # @param [Hash{Symbol => Object}] attributes
    #   Attributes for the record.
    #
    # @option attributes [:r, :s] :adkim (:r)
    #
    # @option attributes [:r, :s] :aspf (:r)
    #
    # @option attributes [Array<'0', '1', 'd', 's'>] :fo ('0')
    #
    # @option attributes [:none, :quarantine, :reject] :p
    #
    # @option attributes [Integer] :pct (100)
    #
    # @option attributes [:afrf, :iodef] :rf (:afrf)
    #
    # @option attributes [Integer] :ri (86400)
    #
    # @option attributes [Array<Uri>] :rua
    #
    # @option attributes [Array<Uri>] :ruf
    #
    # @option attributes [:none, :quarantine, :reject] :sp
    #
    # @option attributes [:DMARC1] :v
    #
    # DMARCbis New tags
    #
    # @option attributes [:none, :quarantine, :reject] :np
    #
    # @option attributes [:y, :n, :u] :psd
    #
    # @option attributes [:y, :n] :t
    #
    def initialize(attributes={})
      @v     = attributes[:v]
      @adkim = attributes[:adkim]
      @aspf  = attributes[:aspf]
      @fo    = attributes[:fo]
      @p     = attributes[:p]
      @pct   = attributes[:pct]
      @rf    = attributes[:rf]
      @ri    = attributes[:ri]
      @rua   = attributes[:rua]
      @ruf   = attributes[:ruf]
      @sp    = attributes[:sp]
      @np    = attributes[:np]
      @psd   = attributes[:psd]
      @t     = attributes[:t]
      @errors = []
    end

    #
    # Determines if the `sp=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def sp?
      !@sp.nil?
    end

    #
    # The `sp=` field.
    attr_writer :sp
    #
    # @return [:none, :quarantine, :reject]
    #   The value of the `sp=` field, or that of {#p} if the field was omitted.
    #
    def sp
      @sp || @p
    end

    #
    # Determines whether the `adkim=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def adkim?
      !@adkim.nil?
    end

    #
    # `adkim=` field.
    attr_writer :adkim
    #
    # @return [:r, :s]
    #   The value of the `adkim=` field, or `:r` if the field was omitted.
    #
    def adkim
      @adkim || 'r'
    end

    #
    # Determines whether the `aspf=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def aspf?
      !@aspf.nil?
    end

    #
    # `aspf=` field.
    attr_writer :aspf
    #
    # @return [:r, :s]
    #   The value of the `aspf=` field, or `:r` if the field was omitted.
    #
    def aspf
      @aspf || 'r'
    end

    #
    # Determines whether the `fo=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def fo?
      !@fo.nil?
    end

    #
    # `fo=` field.
    attr_writer :fo
    #
    # @return [Array<'0', '1', 'd', 's'>]
    #   The value of the `fo=` field, or `["0"]` if the field was omitted.
    #
    def fo
      @fo || %w[0]
    end

    #
    # Determines if the `p=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def p?
      !@p.nil?
    end

    #
    # Determines whether the `pct=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def pct?
      !@pct.nil?
    end

    #
    # `pct` field.
    attr_writer :pct
    #
    # @return [Integer]
    #   The value of the `pct=` field, or `100` if the field was omitted.
    #
    def pct
      @pct || 100
    end

    #
    # Determines whether the `rf=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def rf?
      !@rf.nil?
    end

    #
    # `rf` field.
    attr_writer :rf
    # 
    # @return [:afrf, :iodef]
    #   The value of the `rf=` field, or `:afrf` if the field was omitted.
    #
    def rf
      @rf || 'afrf'
    end

    #
    # Determines whether the `ri=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def ri?
      !@ri.nil?
    end

    #
    # `ri` field.
    attr_writer :ri
    #
    # @return [Integer]
    #   The value of the `ri=` field, or `86400` if the field was omitted.
    #
    def ri
      @ri || 86400
    end

    #
    # `np` field.
    attr_writer :np
    #
    # @return [:none, :quarantine, :reject]
    #   The value of the `np=` field, or that of {#sp, #p} if the field was omitted.
    #
    def np
      @np || @sp || @p
    end

    #
    # Determines whether the `np=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def np?
      !@np.nil?
    end

    #
    # `psd` field.
    attr_writer :psd
    #
    # @return [:y, :n, :u]
    #   The value of the `psd=` field, or `u` if the field was omitted.
    #
    def psd
      @psd || 'u'
    end

    #
    # Determines whether the `psd=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def psd?
      !@psd.nil?
    end

    #
    # `t` field.
    attr_writer :t
    #
    # @return [:y, :n]
    #   The value of the `t=` field, or `n` if the field was omitted.
    #
    def t
      @t || 'n'
    end

    #
    # Determines whether the `t=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def t?
      !@t.nil?
    end

    #
    # Determines if the `rua=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def rua?
      !@rua.nil?
    end

    #
    # Determines if the `ruf=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def ruf?
      !@ruf.nil?
    end

    #
    # Determines if the record have errors
    #
    # @return [Boolean]
    #
    # @since 0.5.0
    #
    def errors?
      @errors.present?
    end


    #
    # Parses a DMARC record.
    #
    # @param [String] record
    #   The raw DMARC record.
    #
    # @return [Record]
    #   The parsed DMARC record.
    #
    # @since 0.3.0
    #
    # @api public
    #
    def self.parse(record)
      record = new(Parser.parse(record))
      record.tap { record.validate! }
    end

    #
    # @deprecated use {parse} instead.
    #
    def self.from_txt(rec)
      parse(rec)
    end

    #
    # Queries and parses the DMARC record for a domain.
    #
    # @param [String] domain
    #   The domain to query DMARC for.
    #
    # @param [Resolv::DNS] resolver
    #   The resolver to use.
    #
    # @return [Record, nil]
    #   The parsed DMARC record. If no DMARC record was found, `nil` will be
    #   returned.
    #
    # @since 0.3.0
    #
    # @api public
    #
    def self.query(domain,resolver=Resolv::DNS.new)
      if (dmarc = DMARC.query(domain,resolver))
        if dmarc.is_a?(String)
          parse(dmarc)
        else
          record = new
          record.errors << Error.new(nil, nil, nil, dmarc.message)
          record
        end
      end
    end

    #
    # Converts the record to a Hash.
    #
    # @return [Hash{Symbol => Object}]
    #
    # @since 0.4.0
    #
    def to_h
      hash = {}

      hash[:v]     = @v     if @v
      hash[:p]     = @p     if @p
      hash[:sp]    = @sp    if @sp
      hash[:np]    = @np    if @np
      hash[:rua]   = @rua   if @rua
      hash[:ruf]   = @ruf   if @ruf
      hash[:adkim] = @adkim if @adkim
      hash[:aspf]  = @aspf  if @aspf
      hash[:fo]    = @fo    if @fo
      hash[:psd]   = @psd   if @psd
      hash[:t]     = @t     if @t
      hash[:pct]   = @pct   if @pct
      hash[:rf]    = @rf    if @rf
      hash[:ri]    = @ri    if @ri
      hash[:errors] = @errors if errors?

      return hash
    end

    #
    # Converts the record back to a DMARC String.
    #
    # @return [String]
    #
    def to_s
      tags = []

      tags << "v=#{@v}"               if @v
      tags << "p=#{@p}"               if @p
      tags << "sp=#{@sp}"             if @sp
      tags << "np=#{@np}"             if @np
      tags << "rua=#{@rua.join(',')}" if @rua
      tags << "ruf=#{@ruf.join(',')}" if @ruf
      tags << "adkim=#{@adkim}"       if @adkim
      tags << "aspf=#{@aspf}"         if @aspf
      tags << "fo=#{@fo.join(':')}"   if @fo
      tags << "psd=#{@psd}"           if @psd
      tags << "t=#{@t}"               if @t
      tags << "pct=#{@pct}"           if @pct
      tags << "rf=#{@rf}"             if @rf
      tags << "ri=#{@ri}"             if @ri

      return tags.join('; ')
    end

    # 
    # Validates the record for any issues.
    # 
    # @return [nil]
    # 
    def validate!
      Validator.validate(self)
    end

  end
end
