// A function that writes a TRACE output of the object and returns the object itself.
// @param obj Any serialisable object
// @returns obj the passed in object
local debug(obj) = (
  std.trace(std.toString(obj), obj)
);

{
  debug(obj): debug(obj),
}
