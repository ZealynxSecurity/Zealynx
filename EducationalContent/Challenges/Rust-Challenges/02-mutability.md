## Cool simple Rust challenge about mutability

What output do you expect from the following Rust code snippet?

```rust
fn main() {
    let mut s = String::from("Rust");
    change(&mut s);
    println!("{}", s);
}

fn change(t: &mut String) {
    t.push_str("aceans");
}
```

Share your answer [here](https://x.com/TheBlockChainer/status/1779499240043233392)

## Syntax explained:

1.  `let mut s = String::from("Rust");`

• `let` is used to declare a new variable.
• `mut` means that the variable `s` is mutable, which means its value can be changed after it's initially set.
• `s` is the name of the variable.
• `String::from("Rust")` is a function call that creates a new `String` object containing the text `"Rust"`. `String` is a growable, heap-allocated data structure used to store text in Rust.

2.  `change(&mut s);`

• `change` is the name of a function that's being called.
• `&mut s` passes a mutable reference to the `s` variable to the `change` function. This allows the `change` function to modify the original string stored in `s` directly. The `&mut` part is crucial because it specifies that the reference is mutable, not just a read-only reference.

3.  `println!("{}", s);`

• `println!` is a macro (not a function, which is why it ends with `!`) that prints text to the console.
• `{}` inside the string is a placeholder used for formatting. It will be replaced by the value of `s`.
• `s` after the comma is the variable that will replace the `{}` in the `println!` string. This is how Rust formats text: you specify placeholders in the string, and then provide the variables to fill in those placeholders after the string.