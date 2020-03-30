require "uri"
require "http"

module Dolly
  abstract class BrowserContext
    property viewport : Size?,
    property ignore_httpserrors : Bool,
    property java_script_enabled : Bool,
    property bypass_csp : Bool,
    property user_agent : String,
    property locale : String,
    property timezone_id : String,
    property geolocation : Geolocation,
    property permissions : string[],
    property extra_httpheaders : HTTP::Headers,
    property offline : Bool,
    property http_credentials : Credentials,
    property device_scale_factor : Int32,
    property is_mobile : Bool,
    property has_touch : Bool

    @timeout_settings : TimeoutSettings
    @page_bindings : Hash(String, PageBinding)
    @routes : Array(Route)
    @closed : Bool
    @permissions : Hash(String, Array(String))

    def initialize(@viewport : Size? = nil,
                   @ignore_httpserrors : Bool = false,
                   @java_script_enabled: Bool = false,
                   @bypass_csp: Bool = false,
                   @user_agent: String = "",
                   @locale: String = "",
                   @timezone_id: String = "",
                   @geolocation: Geolocation? = nil,
                   @permissions: Array(String) = [] of String,
                   @extra_httpheaders: HTTP::Headers? = nil,
                   @offline: Bool = false,
                   @http_credentials: Credentials? = nil,
                   @device_scale_factor: Int32 = 1,
                   @is_mobile: Bool = false,
                   @has_touch: Bool = false)
      @timeout_settings = TimeoutSettings.new()
      @page_bindings = {} of String => PageBinding
      @routes = [] of Route
      @closed = false
      @permissions = {} of String => Array(String)
    end

    # Closed event
    Cute.signal closed

    def set_default_navigation_timeout(timeout : Int32)
      @timeout_settings.set_default_navigation_timeout(timeout)
    end

    def set_default_timeout(timeout : Int32)
      @timeout_settings.set_default_timeout(timeout)
    end

    def grant_permissions(permissions : Array(String), origin : (String | URI)? = nil)
      if origin
        url = URI.parse(origin)
        origin = "#{url.scheme}://#{url.host}"
      else
        origin = "*"
      end

      existing = Set.new(@permissions.get(origin) || [] of String)
      permissions.each do |perm|
        existing << perm
      end
      list = existing.to_a
      @permissions[origin] = list
      do_grant_permissions(origin, list)
    end

    def clear_permissions
      @permissions.clear
      do_clear_permissions
    end

    abstract def pages : Array(Page)
    abstract def new_page : Page
    abstract def cookies(urls : String | Array(String) = [] of String) : HTTP::Cookies
    abstract def add_cookies(cookies : Array(HTTP::Cookie))
    abstract def clear_cookies
    abstract def set_geolocation(geolocation : Geolocation? = nil)
    abstract def set_httpcredentials(httpCredentials : Credentials? = nil)
    abstract def set_extra_httpheaders(headers : HTTP::Headers)
    abstract def set_offline(offline : Bool)
    abstract def add_init_script(script : String | Hash | NamedTuple)
    abstract def expose_function(name: string, &block)
    abstract def route(url : String | Regex | URI, handler : &block : Route, Request ->)
    abstract def close

    private def browser_closed
      pages.each do |page|
        page.did_close
      end
      did_close_internal
    end

    private def did_close_internal
      @closed = true
      self.closed.emit
    end

    private abstract def do_grant_permissions(origin : String, permissions : Array(String))
    private abstract def do_clear_permissions
    # abstract def wait_for_event(event: string, optionsOrPredicate?: Function | (types.TimeoutOptions & { predicate?: Function })) : Promise<any>
  end
end
