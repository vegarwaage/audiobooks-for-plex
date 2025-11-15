# Monkey C Language Essentials

## Overview

Monkey C is an object-oriented programming language designed specifically for Garmin Connect IQ. It combines elements from C, Java, and JavaScript, optimized for wearable devices with limited resources.

## Basic Syntax

### Hello World

```monkey-c
using Toybox.System;

class HelloWorld {
    function initialize() {
        System.println("Hello, Connect IQ!");
    }
}
```

### Comments

```monkey-c
// Single-line comment

/*
 * Multi-line comment
 * Can span multiple lines
 */

/* Inline comment */
```

---

## Data Types

### Primitive Types

#### Numbers

Monkey C has a single numeric type that represents integers and floats:

```monkey-c
var integer = 42;
var negative = -10;
var float = 3.14159;
var scientific = 1.5e6;  // 1500000

// Hexadecimal
var hex = 0xFF;           // 255

// Type conversions
var str = "123";
var num = str.toNumber();  // 123
var back = num.toString(); // "123"
```

#### Booleans

```monkey-c
var isTrue = true;
var isFalse = false;

// Boolean operations
var and = true && false;   // false
var or = true || false;    // true
var not = !true;           // false
```

#### Strings

```monkey-c
var str1 = "Hello";
var str2 = "World";

// Concatenation
var greeting = str1 + " " + str2;  // "Hello World"

// String methods
var length = str1.length();         // 5
var upper = str1.toUpper();        // "HELLO"
var lower = str1.toLower();        // "hello"
var sub = str1.substring(0, 4);    // "Hell"

// String comparison
var equal = str1.equals(str2);     // false

// Escape sequences
var escaped = "Line 1\nLine 2\tTabbed";
var quoted = "He said \"Hello\"";
```

#### Null

```monkey-c
var nothing = null;

// Null checking
if (nothing == null) {
    System.println("Value is null");
}

// Null-safe access
var value = getData();
if (value != null) {
    var result = value.process();
}
```

### Collections

#### Arrays

```monkey-c
// Array creation
var empty = [];
var numbers = [1, 2, 3, 4, 5];
var mixed = [1, "two", 3.0, true];

// Array access
var first = numbers[0];           // 1
numbers[0] = 10;                  // Modify element

// Array methods
var size = numbers.size();        // 5
numbers.add(6);                   // Add element
numbers.addAll([7, 8, 9]);       // Add multiple

// Array operations
var index = numbers.indexOf(3);   // 2
var slice = numbers.slice(0, 3); // [1, 2, 3]

// Iteration
for (var i = 0; i < numbers.size(); i++) {
    System.println(numbers[i]);
}
```

#### Dictionaries (Hash Maps)

```monkey-c
// Dictionary creation
var empty = {};
var person = {
    "name" => "John",
    "age" => 30,
    "active" => true
};

// Numeric keys
var indexed = {
    0 => "first",
    1 => "second",
    2 => "third"
};

// Mixed keys
var mixed = {
    "string" => 1,
    :symbol => 2,
    0 => 3
};

// Access
var name = person["name"];        // "John"
var age = person.get("age");      // 30

// Modification
person["age"] = 31;
person.put("city", "Portland");

// Check existence
var hasName = person.hasKey("name");  // true

// Keys and values
var keys = person.keys();         // ["name", "age", "active"]
var values = person.values();     // ["John", 30, true]

// Iteration
var keys = person.keys();
for (var i = 0; i < keys.size(); i++) {
    var key = keys[i];
    var value = person[key];
    System.println(key + ": " + value);
}
```

#### Symbols

Symbols are lightweight identifiers used as keys:

```monkey-c
var options = {
    :theme => "dark",
    :fontSize => 12,
    :enabled => true
};

var theme = options[:theme];      // "dark"
options[:theme] = "light";

// Symbol advantage: More efficient than strings
// Common in API usage
Position.enableLocationEvents(
    Position.LOCATION_CONTINUOUS,
    method(:onPosition)
);
```

---

## Variables and Constants

### Variable Declaration

```monkey-c
// Local variables
var count = 0;
var name = "John";
var isActive = true;

// Type is inferred from value
var number = 42;         // Number
var text = "Hello";      // String
var items = [];          // Array
var data = {};           // Dictionary
```

### Constants

```monkey-c
// Module-level constants
const PI = 3.14159;
const APP_NAME = "My App";
const MAX_ITEMS = 100;

// Constants must be initialized
const DEFAULT_COLOR = Graphics.COLOR_BLUE;
```

### Scope

```monkey-c
class MyClass {
    // Class-level variables (instance variables)
    private var _privateVar;
    var publicVar;

    // Module-level variables (static-like)
    static var sharedVar = 0;

    function myMethod() {
        // Local variables
        var localVar = 10;

        // Access instance variables
        _privateVar = 20;
        publicVar = 30;

        // Access class variables
        MyClass.sharedVar = 40;
    }
}
```

---

## Operators

### Arithmetic Operators

```monkey-c
var a = 10;
var b = 3;

var sum = a + b;          // 13
var diff = a - b;         // 7
var product = a * b;      // 30
var quotient = a / b;     // 3 (integer division)
var remainder = a % b;    // 1

// Unary operators
var neg = -a;             // -10
var pos = +a;             // 10

// Increment/Decrement
a++;                      // a = 11
a--;                      // a = 10
++a;                      // a = 11
--a;                      // a = 10
```

### Comparison Operators

```monkey-c
var x = 5;
var y = 10;

var equal = x == y;           // false
var notEqual = x != y;        // true
var less = x < y;             // true
var lessEqual = x <= y;       // true
var greater = x > y;          // false
var greaterEqual = x >= y;    // false

// String comparison
"abc".equals("abc");          // true
"abc" == "abc";              // true
```

### Logical Operators

```monkey-c
var a = true;
var b = false;

var and = a && b;         // false
var or = a || b;          // true
var not = !a;             // false

// Short-circuit evaluation
var result = true || expensiveOperation();  // expensiveOperation not called
```

### Bitwise Operators

```monkey-c
var a = 0b1010;  // 10
var b = 0b1100;  // 12

var and = a & b;     // 0b1000 (8)
var or = a | b;      // 0b1110 (14)
var xor = a ^ b;     // 0b0110 (6)
var not = ~a;        // Bitwise NOT

var left = a << 2;   // 0b101000 (40)
var right = a >> 2;  // 0b0010 (2)
```

### Assignment Operators

```monkey-c
var x = 10;

x += 5;          // x = x + 5
x -= 3;          // x = x - 3
x *= 2;          // x = x * 2
x /= 4;          // x = x / 4
x %= 3;          // x = x % 3

// Bitwise assignment
x &= 0xFF;
x |= 0x01;
x ^= 0x10;
```

---

## Control Flow

### If-Else Statements

```monkey-c
var score = 85;

if (score >= 90) {
    System.println("A");
} else if (score >= 80) {
    System.println("B");
} else if (score >= 70) {
    System.println("C");
} else {
    System.println("F");
}

// Ternary operator
var result = score >= 60 ? "Pass" : "Fail";

// Single-line if
if (score >= 60) { System.println("Pass"); }
```

### Switch Statements

```monkey-c
var day = 3;

switch (day) {
    case 1:
        System.println("Monday");
        break;
    case 2:
        System.println("Tuesday");
        break;
    case 3:
        System.println("Wednesday");
        break;
    default:
        System.println("Other day");
        break;
}

// Fall-through (no break)
switch (day) {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
        System.println("Weekday");
        break;
    case 6:
    case 7:
        System.println("Weekend");
        break;
}
```

### For Loops

```monkey-c
// Standard for loop
for (var i = 0; i < 10; i++) {
    System.println(i);
}

// Iterate array
var items = [1, 2, 3, 4, 5];
for (var i = 0; i < items.size(); i++) {
    System.println(items[i]);
}

// Reverse iteration
for (var i = items.size() - 1; i >= 0; i--) {
    System.println(items[i]);
}

// Nested loops
for (var i = 0; i < 3; i++) {
    for (var j = 0; j < 3; j++) {
        System.println(i + "," + j);
    }
}
```

### While Loops

```monkey-c
var count = 0;
while (count < 5) {
    System.println(count);
    count++;
}

// Condition at start
var i = 0;
while (i < items.size()) {
    System.println(items[i]);
    i++;
}
```

### Do-While Loops

```monkey-c
var count = 0;
do {
    System.println(count);
    count++;
} while (count < 5);

// Executes at least once
var value = getData();
do {
    processData(value);
    value = getData();
} while (value != null);
```

### Break and Continue

```monkey-c
// Break - exit loop
for (var i = 0; i < 10; i++) {
    if (i == 5) {
        break;  // Exit loop
    }
    System.println(i);
}

// Continue - skip iteration
for (var i = 0; i < 10; i++) {
    if (i % 2 == 0) {
        continue;  // Skip even numbers
    }
    System.println(i);
}
```

---

## Functions

### Function Declaration

```monkey-c
// Basic function
function greet(name) {
    return "Hello, " + name;
}

// Call function
var message = greet("John");

// Multiple parameters
function add(a, b) {
    return a + b;
}

// No return value (returns null)
function printMessage(msg) {
    System.println(msg);
}

// Default behavior (no explicit return)
function doSomething() {
    // Returns null implicitly
}
```

### Function Parameters

```monkey-c
// Positional parameters
function createPerson(name, age, city) {
    return {
        :name => name,
        :age => age,
        :city => city
    };
}

var person = createPerson("John", 30, "Portland");

// Optional parameters (check for null)
function greet(name, title) {
    var prefix = title != null ? title : "Mr./Ms.";
    return prefix + " " + name;
}

greet("Smith");          // "Mr./Ms. Smith"
greet("Smith", "Dr.");   // "Dr. Smith"
```

### Return Values

```monkey-c
// Single return
function square(x) {
    return x * x;
}

// Multiple return points
function getGrade(score) {
    if (score >= 90) { return "A"; }
    if (score >= 80) { return "B"; }
    if (score >= 70) { return "C"; }
    return "F";
}

// Return complex objects
function getUser() {
    return {
        :name => "John",
        :age => 30
    };
}

// Return arrays
function getNumbers() {
    return [1, 2, 3, 4, 5];
}
```

### Method References

```monkey-c
class MyClass {
    function onPosition(info) {
        System.println("Position: " + info.position);
    }

    function start() {
        // Pass method as callback
        Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:onPosition)
        );
    }
}
```

---

## Classes and Objects

### Class Declaration

```monkey-c
using Toybox.System;

class Person {
    // Instance variables
    var name;
    var age;

    // Constructor
    function initialize(name, age) {
        self.name = name;
        self.age = age;
    }

    // Instance method
    function introduce() {
        System.println("I'm " + name + ", age " + age);
    }

    // Getter-like method
    function getName() {
        return name;
    }

    // Setter-like method
    function setName(newName) {
        name = newName;
    }
}

// Create instance
var person = new Person("John", 30);
person.introduce();

// Access members
var name = person.name;
person.age = 31;
```

### Inheritance

```monkey-c
// Base class
class Animal {
    var name;

    function initialize(name) {
        self.name = name;
    }

    function speak() {
        System.println("Some sound");
    }
}

// Derived class
class Dog extends Animal {
    var breed;

    function initialize(name, breed) {
        Animal.initialize(name);
        self.breed = breed;
    }

    // Override method
    function speak() {
        System.println("Woof!");
    }

    // New method
    function fetch() {
        System.println(name + " is fetching");
    }
}

var dog = new Dog("Buddy", "Labrador");
dog.speak();    // "Woof!"
dog.fetch();    // "Buddy is fetching"
```

### Access Modifiers

```monkey-c
class BankAccount {
    // Public (default)
    var accountNumber;

    // Private (convention: prefix with _)
    private var _balance;
    private var _pin;

    function initialize(accountNumber) {
        self.accountNumber = accountNumber;
        _balance = 0;
        _pin = "0000";
    }

    // Public method
    function deposit(amount) {
        _balance += amount;
    }

    // Public method
    function getBalance() {
        return _balance;
    }

    // Private method
    private function validatePin(pin) {
        return pin.equals(_pin);
    }
}
```

### Static Members

Monkey C doesn't have true static members, but you can use module-level variables:

```monkey-c
module Utils {
    var _instance = null;

    function getInstance() {
        if (_instance == null) {
            _instance = new MyClass();
        }
        return _instance;
    }
}

// Usage
var obj = Utils.getInstance();
```

---

## Modules

### Module Declaration

```monkey-c
module MyModule {
    var moduleVar = 10;

    function moduleFunction() {
        return "Hello from module";
    }

    class ModuleClass {
        function initialize() {
        }
    }
}

// Usage
var value = MyModule.moduleVar;
var result = MyModule.moduleFunction();
var obj = new MyModule.ModuleClass();
```

### Nested Modules

```monkey-c
module App {
    module Utils {
        function formatNumber(n) {
            return n.format("%d");
        }
    }

    module Models {
        class User {
            var name;
            function initialize(name) {
                self.name = name;
            }
        }
    }
}

// Usage
var formatted = App.Utils.formatNumber(42);
var user = new App.Models.User("John");
```

---

## Using Statements

### Import Toybox Modules

```monkey-c
using Toybox.System;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Application;

// Now can use without prefix
System.println("Hello");
var color = Graphics.COLOR_BLUE;
```

### Import Custom Modules

```monkey-c
// File: Utils.mc
module Utils {
    function helper() {
        return "Help";
    }
}

// File: Main.mc
using Utils;

function main() {
    var result = Utils.helper();
}
```

---

## Exception Handling

### Try-Catch

```monkey-c
try {
    var result = riskyOperation();
    processResult(result);
} catch (e) {
    System.println("Error: " + e.getErrorMessage());
    // Handle error
}

// Multiple operations
try {
    var data = fetchData();
    if (data == null) {
        throw new Exception.InvalidValueException("Data is null");
    }
    return processData(data);
} catch (e instanceof Communications.InvalidHttpBodyException) {
    System.println("Invalid HTTP body");
} catch (e) {
    System.println("Unknown error: " + e.getErrorMessage());
}
```

### Throw Exceptions

```monkey-c
function divide(a, b) {
    if (b == 0) {
        throw new Exception.InvalidValueException("Division by zero");
    }
    return a / b;
}

// Usage
try {
    var result = divide(10, 0);
} catch (e) {
    System.println("Error: " + e.getErrorMessage());
}
```

---

## Special Features

### String Formatting

```monkey-c
using Toybox.Lang;

// Basic formatting
var name = "John";
var age = 30;
var message = Lang.format("$1$ is $2$ years old", [name, age]);
// "John is 30 years old"

// Number formatting
var pi = 3.14159;
var formatted = pi.format("%.2f");  // "3.14"
var integer = 42;
var padded = integer.format("%03d");  // "042"
```

### Type Checking

```monkey-c
var value = getSomeValue();

// Check type
if (value instanceof String) {
    System.println("It's a string");
} else if (value instanceof Number) {
    System.println("It's a number");
} else if (value instanceof Array) {
    System.println("It's an array");
}

// Check for null
if (value != null) {
    // Safe to use
}

// Check class
if (value instanceof MyClass) {
    value.myMethod();
}
```

### Annotations

```monkey-c
// Test annotation
(:test)
function myTest(logger) {
    return true;
}

// Debug annotation
(:debug)
function debugFunction() {
    System.println("Debug info");
}

// Exclude for specific devices
(:exclude_low_memory)
function highMemoryFeature() {
    // Only included for high-memory devices
}

// Type annotations (for compiler)
function calculate(x as Number, y as Number) as Number {
    return x + y;
}
```

---

## Best Practices

### Naming Conventions

```monkey-c
// Classes: PascalCase
class MyClass { }

// Functions/Methods: camelCase
function myFunction() { }

// Variables: camelCase
var myVariable = 10;

// Constants: UPPER_SNAKE_CASE
const MAX_VALUE = 100;

// Private members: prefix with underscore
private var _privateVar;
```

### Code Organization

```monkey-c
// Group related functionality
module Services {
    class NetworkService { }
    class StorageService { }
}

// Use meaningful names
function calculateAverageHeartRate(samples) {
    // Clear purpose
}

// Avoid magic numbers
const DEFAULT_TIMEOUT = 30;
const MAX_RETRIES = 3;
```

### Error Handling

```monkey-c
// Always check for null
var position = Activity.getActivityInfo().currentLocation;
if (position != null) {
    var lat = position.toRadians()[0];
}

// Use try-catch for risky operations
try {
    var result = Communications.makeWebRequest(url, params, options, callback);
} catch (e) {
    System.println("Network error: " + e.getErrorMessage());
}
```

---

## Resources

- **API Documentation**: https://developer.garmin.com/connect-iq/api-docs/
- **Language Reference**: https://developer.garmin.com/connect-iq/monkey-c/
- **Sample Code**: https://github.com/garmin/connectiq-apps
