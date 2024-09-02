## Go Channels

Send to a `nil` channel blocks forever
Receive from a `nil` channel blocks forever
Send on a closed channel panics
Receive on a closed channel returns the 0-value of the channel type
Receiving without a sender blocks
Sending without a receiver blocks
Sending to a full buffered channel blocks

## Array Assignment

Prefer `copy(a[i], val)` over `a[i] := val`. Safer from nil panics

## Append

Append is nil-safe - the map/slice doesn't _need_ to be initialized. Prefer doing so if you can, though.

## HTTP QueryParams & Semicolons

Go 1.18 appeared to have dropped support for the old pattern of using `;` as a query parameter separator. https://github.com/golang/go/issues/50034 still tracks this as an issue since 2021.

_Most_ modern clients dropped `;` as a valid separator years ago in favor of `&`. Some devs still use them. The [RFC](https://datatracker.ietf.org/doc/html/rfc3986#section-2.2) lists them as a `sub-delim` role. In general, it _shouldn't_ be a problem but, just in case, you have to add a HTTP middleware or support function to handle it:

```go
// SemicolonReadCloser replaces `;` with `&`. This should ONLY
// be used to support old HTTP clients
type SemicolonReadCloser struct {
    r io.ReadCloser
}

func (rc SemicolonReadCloser) Read(p []byte) (n int, err error) {
	const semi = ';'
	const amp = '&'
	n, err := rc.r.Read(p); 
	if err != nil {
		if !errors.Is(err, io.EOF) {
			return n, err
		}
	}
	for i := 0; i < len(p); i++ {
		if p[i] == semi {
			p[i] == amp
		}
	}
	return n, err
}

func (rc SemicolonReadCloser) Close() error {
	return rc.r.Close()
}
```