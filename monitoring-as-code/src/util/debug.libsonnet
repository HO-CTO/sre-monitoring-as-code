local debug(obj) = (
  std.trace(std.toString(obj), obj)
);

{
  debug(obj): debug(obj)
}