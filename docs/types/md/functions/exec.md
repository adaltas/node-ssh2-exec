[**ssh2-exec**](../README.md)

---

[ssh2-exec](../README.md) / exec

# Function: exec()

## Call Signature

> **exec**(`options`, `callback?`): `ChildProcess`

Defined in: [index.ts:196](https://github.com/adaltas/node-ssh2-exec/blob/7db8597fae43bab37cafc4a9b1d259fcd2db47fe/src/index.ts#L196)

### Parameters

#### options

[`ExecOptions`](../type-aliases/ExecOptions.md)

#### callback?

[`ExecCallback`](../type-aliases/ExecCallback.md)

### Returns

`ChildProcess`

## Call Signature

> **exec**(`ssh`, `command`, `callback?`): `ChildProcess`

Defined in: [index.ts:200](https://github.com/adaltas/node-ssh2-exec/blob/7db8597fae43bab37cafc4a9b1d259fcd2db47fe/src/index.ts#L200)

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

Defined in: [index.ts:205](https://github.com/adaltas/node-ssh2-exec/blob/7db8597fae43bab37cafc4a9b1d259fcd2db47fe/src/index.ts#L205)

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
