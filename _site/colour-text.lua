
Span = function(span)
  color = span.attributes['colour']
  -- if no color attribute, return unchange
  if colour == nil then return span end

  -- tranform to <span style="color: red;"></span>
  if FORMAT:match 'html' then
    -- remove color attributes
    span.attributes['colour'] = nil
    -- use style attribute instead
    span.attributes['style'] = 'color: ' .. colour .. ';'
    -- return full span element
    return span
  elseif FORMAT:match 'latex' then
    -- remove color attributes
    span.attributes['colour'] = nil
    -- encapsulate in latex code
    table.insert(
      span.content, 1,
      pandoc.RawInline('latex', '\\textcolor{'..colour..'}{')
    )
    table.insert(
      span.content,
      pandoc.RawInline('latex', '}')
    )
    -- returns only span content
    return span.content
  else
    -- for other format return unchanged
    return span
  end
end
