module Dolly
  alias Size = NamedTuple(width: Int32, height: Int32)
  alias Point = NamedTuple(x: Int32, y: Int32)
  alias Rect = NamedTuple(width: Int32, height: Int32, x: Int32, y: Int32)
  alias Quad = Tuple(Point, Point, Point, Point)

  record Geolocation,
    longitude : Int32,
    latitude : Int32,
    accuracy : Int32? = nil

  record Credentials,
    username : String,
    password : String

  record Route,
    url : String | Regex | URI,
    handler : RouteHandler
end
