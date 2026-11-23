;; extends

;; HTMX attributes
(attribute
  (attribute_name) @_attr_name
  [
    (attribute_value) @attribute.htmx
    (quoted_attribute_value
      (attribute_value) @attribute.htmx)
  ]
  (#match? @_attr_name "^hx-"))

;; Tag with HTMX attributes
(start_tag
  (tag_name) @tag.htmx
  (attribute
    (attribute_name) @_attr_name)
  (#match? @_attr_name "^hx-"))
