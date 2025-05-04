
;; HTMX attributes
(
  (attribute
    (attribute_name) @_attr_name
    (attribute_value) @attribute.htmx)
  (#match? @_attr_name "^hx-")
)

;; Tag with HTMX attributes
(
  (element
    (start_tag
      (attribute
        (attribute_name) @_attr_name)))
  @tag.htmx
  (#match? @_attr_name "^hx-")
)

