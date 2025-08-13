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

# modification retains comments

    Code
      cat(text_modify(text, "foo", 0))
    Output
      
      {
          // a
          "foo": 0, // b
          "bar": [
              // c
              1,
              2, // d
              // e
              3
          ] // f
          // g
      }
        

---

    Code
      options <- modification_options(is_array_insertion = FALSE)
      cat(text_modify(text, list("bar", 2), 0, modification_options = options))
    Output
      
      {
          // a
          "foo": 1, // b
          "bar": [
              // c
              1,
              0, // d
              // e
              3
          ] // f
          // g
      }
        

---

    Code
      options <- modification_options(is_array_insertion = TRUE)
      cat(text_modify(text, list("bar", 2), 0, modification_options = options))
    Output
      
      {
          // a
          "foo": 1, // b
          "bar": [
              // c
              1,
              0,
              2, // d
              // e
              3
          ] // f
          // g
      }
        

---

    Code
      cat(text_modify(text, "new", 0))
    Output
      
      {
          // a
          "foo": 1, // b
          "bar": [
              // c
              1,
              2, // d
              // e
              3
          ],
          "new": 0 // f
          // g
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

