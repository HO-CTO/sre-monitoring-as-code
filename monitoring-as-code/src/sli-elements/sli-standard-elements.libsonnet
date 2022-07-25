// File for creating standard elements for an SLI object

local createSliStandardElements(sliKey, sliSpec) =
  {
    key: sliKey,
    title: sliSpec.title,
  };

// File exports
{
  createSliStandardElements(sliKey, sliSpec): createSliStandardElements(sliKey, sliSpec),
}
