#!/usr/bin/env ruby
require 'dl/import'

module Intersys
  extend DL::Importable
  dlload("/Applications/intersys/bin/libcbind.dylib")
  class intersysException < StandardError
  end
  
  class ObjectNotFound < intersysException
  end
  
  class MarshallError < intersysException
  end

  class UnMarshallError < intersysException
  end
  
  class ConnectionError < intersysException
  end
  
  def self.handle_error(error_code, message, file, line)
    #raise ConnectionError if error_code == 461
  end
  
  class Definition
    def initialize(database, class_name, name)
      @database = database
      @class_name = class_name
      @name = name
      intern_initialize(database, class_name, name)
    end
  end
  
  class Property < Definition
  end
  
  class Method < Definition
    attr_accessor :args
  protected
    def arg!
      Argument.new(@database, @class_name, @name, self)
    end
  public
    
    def initialize(database, class_name, name)
      super(database, class_name, "%"+name.to_s.capitalize)
      method_initialize
      @args = []
      num_args.times do
        @args << arg!
      end
    end
    
    def call(object, *method_args)
      prepare_call!
      raise ArgumentError, "wrong number of arguments (#{method_args.size} for #{args.size})" if args.size < method_args.size
      args.each_with_index do |arg, i|
        arg.set!(method_args[i])
      end
      intern_call!(object)
      extract_retval!
    end
  end
  
  class Argument < Definition
    def marshall_dlist(list)
      list.each do |elem|
        marshall_dlist_element(elem)
      end
    end
  end
  
  class Status
    attr_accessor :code
    attr_accessor :message
    def initialize(code, message)
      @code = code
      @message = message
    end
  end

  require 'intersys'
  

  class Object
protected
    @@class_names = {}
    def self.class_names
      @@class_names
    end
    
    def self.set_class_name(name)
      if name.index(".")
        prefix name.split(".").first
        @class_name = name
      else
        @class_name = prefix + "." + name
      end
      @class_name = @class_name.to_wchar
    end
    
    def self.calculate_class_name
    end
      
    def self.get_class_name
      @class_name ? @class_name.from_wchar : nil
    end

public
    def self.prefix(prefix_name = nil)
      if prefix_name
        @prefix = prefix_name.to_wchar
      end
      @prefix.from_wchar
    end

    
    def self.class_name(name = nil)
      if name
        Cache::Object.class_names[name] = self
        set_class_name(name)
      end
      get_class_name
    end

    def self.database(db = nil)
      @@database = db if db
      @@database
    end
    

    
    def self.concurrency
      1
    end
    
    def self.timeout
      5
    end
    
    def self.create
      create_intern
    end

    def self.open(id)
      open_intern(id.to_s.to_wchar)
    end
    
    def self.property(name)
      Property.new(database, class_name, name.to_s.to_wchar)
    end
    
    def self.method(name)
      Method.new(database, class_name, name.to_s.to_wchar)
    end
    
    def self.method_missing(method_name, *args)
      method(method_name).call(nil, *args)
    end
    
    
    def intersys_methods
      @@methods ||= intern_methods.map{|method| method.from_wchar.downcase.to_sym}
    end
    
    def intersys_properties
      @@properties ||= intern_properties.map{|prop| prop.from_wchar.downcase.to_sym}
    end
    
    def intersys_setters
      @@setters ||= intersys_properties.map {|prop| "#{prop}=".to_sym}
    end
    
    def intersys_get(property)
      intern_get(self.class.property(property))
    end
    
    def intersys_set(property, value)
      intern_set(self.class.property(property), value)
    end
    
    def intersys_call(method, *args)
      self.class.method(method).call(self, *args)
    end
    
    def method_missing(method, *args)
      if match_data = method.to_s.match(/(\w+)=/)
        return intersys_set(match_data.captures.first, args.first)
      end
      begin
        return intersys_get(method)
      rescue
        begin
          return intersys_call(method, args)
        rescue
        end
      end
      super(method, *args)
    end
    
    def save
      intersys_call("%Save")
    end
    
    def id
      intersys_call("%Id").to_i
    end
  end
  
  class Query
    attr_reader :database
    
    def initialize(database, query)
      @database = database
      native_initialize(database, query.to_wchar)
    end
    
    
  end
  
  class Database
    def create_query(query)
      Query.new(self, query)
    end
    
    def query(query)
      create_query(query).execute.fetch
    end
  end
end
