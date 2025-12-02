[**ssh2-exec**](../README.md)

---

[ssh2-exec](../README.md) / exec

# Function: exec()

## Call Signature

> **exec**(`options`, `callback?`): `ChildProcess`

Defined in: [index.ts:194](https://github.com/adaltas/node-ssh2-exec/blob/083163baf1b413e01be4f74ceee61972df68f351/src/index.ts#L194)

### Parameters

#### options

[`ExecOptions`](../type-aliases/ExecOptions.md)

#### callback?

[`ExecCallback`](../type-aliases/ExecCallback.md)

### Returns

`ChildProcess`

## Call Signature

> **exec**(`ssh`, `command`, `callback?`): `ChildProcess`

Defined in: [index.ts:198](https://github.com/adaltas/node-ssh2-exec/blob/083163baf1b413e01be4f74ceee61972df68f351/src/index.ts#L198)

### Parameters

#### ssh

`Client` | `null`

#### command

`string`

#### callback?

[`ExecCallback`](../type-aliases/ExecCallback.md)

### Returns

`ChildProcess`

## Call Signature

> **exec**(`ssh`, `command`, `options`, `callback?`): `ChildProcess`

Defined in: [index.ts:203](https://github.com/adaltas/node-ssh2-exec/blob/083163baf1b413e01be4f74ceee61972df68f351/src/index.ts#L203)

### Parameters

#### ssh

`Client` | `null`

#### command

`string`

#### options

[`ExecOptions`](../type-aliases/ExecOptions.md)

#### callback?

[`ExecCallback`](../type-aliases/ExecCallback.md)

### Returns

`ChildProcess`
