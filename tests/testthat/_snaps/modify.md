# can modify objects by name

    Code
      cat(text_modify("{}", "foo", 1))
    Output
      {
          "foo": 1
      }

---

    Code
      cat(text_modify("{}", "foo", 1:2))
    Output
      {
          "foo": [
              1,
              2
          ]
      }

---

    Code
      cat(text_modify("{}", "foo", list(1, "x")))
    Output
      {
          "foo": [
              1,
              "x"
          ]
      }

# can't modify non-object non-array parents

    Code
      text_modify("1", "foo", 0)
    Condition
      Error:
      ! Error: Can not add index to parent of type number

---

    Code
      text_modify("\"a\"", "foo", 0)
    Condition
      Error:
      ! Error: Can not add index to parent of type string

---

    Code
      text_modify("true", "foo", 0)
    Condition
      Error:
      ! Error: Can not add index to parent of type boolean

---

    Code
      text_modify("null", "foo", 0)
    Condition
      Error:
      ! Error: Can not add index to parent of type null

