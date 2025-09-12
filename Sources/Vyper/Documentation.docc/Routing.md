#  Routes


## Parameters

Each method parameter of a route must be annotated to indicate how the value will be extracted from the request.


### Path Components

``Path`` Parameters are decoded from a path component of the request. 
The parameter type must be a string or alternatively conform to ``LosslessStringConvertible``. 
The first name of the parameter must match a component in the route path 

```
/// /hello/Ben
@GET("hello", ":name")
func greet(@Path name: String) -> String {
    return "Hello, \(name)!"
}
```

### Query Parameters
``Query`` Parameters are decoded from the query items of the request. 
The parameter type must be a string or alternatively conform to ``LosslessStringConvertible``. 
The first name of the parameter is the name of the query item. 

```
/// /hello?name=Ben
@GET("hello")
func greet(@Query name: String) -> String {
    return "Hello, \(name)!"
}
```

### ``Header``
``Header`` Parameters are decoded from the headers of the request. 
The parameter type must be a string or alternatively conform to ``LosslessStringConvertible``. 
The first name of the parameter is the name of the header item. 

```
/// /hello?name=Ben
@GET("hello")
func greet(@Query name: String) -> String {
return "Hello, \(name)!"
}
```

### ``Body``

### ``Field``

### ``Passthrough``
