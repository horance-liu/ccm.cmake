# ccm.cmake: c/c++ module utilities in cmake  

**ccm.cmake** it is a simple dsl likes bazel for c/c++ target in cmake.

## Outline

### cc_library

```cmake
cc_library(
    NAME name
    [NAMESPACE namespace]
    [ENABLE_INSTALL]
    [<DEPS|PRIVATE_DEPS|PUBLIC_DEPS|INTERFACE_DEPS> <dep>...]...
    [<INCLS|PRIVATE_INCLS|PUBLIC_INCLS|INTERFACE_INCLS> <incl>...]...
    [<DEFINES|PRIVATE_DEFINES|PUBLIC_DEFINES|INTERFACE_DEFINES> <def>...]...        
    [<CFETURES|PRIVATE_CFETURES|PUBLIC_CFETURES|INTERFACE_CFETURES> <feature>...]...
    [<COPTS|PRIVATE_COPTS|PUBLIC_COPTS|INTERFACE_COPTS> <copt>...]...
    [<LOPTS|PRIVATE_LOPTS|PUBLIC_LOPTS|INTERFACE_LOPTS> <lopt>...]...
    [<LPATHS|PRIVATE_LPATHS|PUBLIC_LPATHS|INTERFACE_LPATHS> <path>...]...
)
```

The `PUBLIC, PRIVATE and INTERFACE` prefix(default is PRIVATE in order to hide detals for implement with best effort) can be used to specify both the link dependencies and the link interface in one command. Libraries and targets following PUBLIC are linked to, and are made part of the link interface. Libraries and targets following PRIVATE are linked to, but are not made part of the link interface. Libraries following INTERFACE are appended to the link interface and are not used for linking <target>.

### cc_binary

```cmake
cc_binary(
    NAME name
    [NAMESPACE namespace]
    [ENABLE_INSTALL]
    [ENABLE_TEST]
    [<DEPS|PRIVATE_DEPS> <dep>...]...
    [<INCLS|PRIVATE_INCLS> <incl>...]...
    [<DEFINES|PRIVATE_DEFINES> <def>...]...        
    [<CFETURES|PRIVATE_CFETURES> <feature>...]...
    [<COPTS|PRIVATE_COPTS> <copt>...]...
    [<LOPTS|PRIVATE_LOPTS> <lopt>...]...
    [<LPATHS|PRIVATE_LPATHS> <path>...]...
)
```

The `PUBLIC, PRIVATE and INTERFACE` prefix(default is PRIVATE) can be used to specify both the link dependencies and the link interface in one command. Libraries and targets following PUBLIC are linked to, and are made part of the link interface. Libraries and targets following PRIVATE are linked to, but are not made part of the link interface. Libraries following INTERFACE are appended to the link interface and are not used for linking <target>.


### cc_test

```cmake
cc_test(
    NAME name
    [NAMESPACE namespace]
    [<DEPS|PRIVATE_DEPS> <dep>...]...
    [<INCLS|PRIVATE_INCLS> <incl>...]...
    [<DEFINES|PRIVATE_DEFINES> <def>...]...        
    [<CFETURES|PRIVATE_CFETURES> <feature>...]...
    [<COPTS|PRIVATE_COPTS> <copt>...]...
    [<LOPTS|PRIVATE_LOPTS> <lopt>...]...
    [<LPATHS|PRIVATE_LPATHS> <path>...]...
)
```

The `PUBLIC, PRIVATE and INTERFACE` prefix(default is PRIVATE) can be used to specify both the link dependencies and the link interface in one command. Libraries and targets following PUBLIC are linked to, and are made part of the link interface. Libraries and targets following PRIVATE are linked to, but are not made part of the link interface. Libraries following INTERFACE are appended to the link interface and are not used for linking <target>.

### cc_flink

```cmake
cc_flink(<target>
    <PRIVATE|PUBLIC|INTERFACE> <item>...
    [<PRIVATE|PUBLIC|INTERFACE> <item>...]...
)
```

The `PUBLIC, PRIVATE and INTERFACE` keywords can be used to specify both the link dependencies and the link interface in one command. Libraries and targets following PUBLIC are linked to, and are made part of the link interface. Libraries and targets following PRIVATE are linked to, but are not made part of the link interface. Libraries following INTERFACE are appended to the link interface and are not used for linking <target>.

### Namespace

```
set(CCM_NAMESPACE <domain_namespace>)
```

Simplistically, after setting `CCM_NAMESPACE` variable will add namespace to targets created in the current directory scope and below.

Dependence `:dep_name` with prefix `:` for `DEPS|PRIVATE_DEPS|PUBLIC_DEPS|INTERFACE_DEPS` in the same namespace, the framework will prepend full name for dependency; otherwise must define full `namespace::dep_name` for dependence explicitly.

### TODO

- ENABLE_INSTALL: 
- TEST_ONLY

## Example

- [ccm.cmake example](example)
