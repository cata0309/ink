` the ink standard library `

log := str => (
	out(str + '
')
)

scan := callback => (
	acc := ['']
	cb := evt => evt.type :: {
		'end' -> callback(acc.0)
		'data' -> (
			acc.0 :=
				acc.0 + slice(evt.data, 0, len(evt.data) - 1)
			false
		)
	}
	in(cb)
)

` clamp start and end numbers to ranges, such that
	start < end. Utility used in slice/sliceList`
clamp := (start, end, min, max) => (
	start := (start < min :: {
		true -> min
		false -> start
	})
	end := (end < min :: {
		true -> min
		false -> end
	})
	end := (end > max :: {
		true -> max
		false -> end
	})
	start := (start > end :: {
		true -> end
		false -> start
	})

	{
		start: start,
		end: end,
	}
)

` get a substring of a given string `
slice := (str, start, end) => (
	result := ['']

	` bounds checks `
	x := clamp(start, end, 0, len(str))
	start := x.start
	end := x.end

	(sl := idx => idx :: {
		end -> result.0
		_ -> (
			result.0 := result.0 + str.(idx)
			sl(idx + 1)
		)
	})(start)
)

` get a sub-list of a given list `
sliceList := (list, start, end) => (
	result := []

	` bounds checks `
	x := clamp(start, end, 0, len(list))
	start := x.start
	end := x.end

	(sl := idx => idx :: {
		end -> result
		_ -> (
			result.(len(result)) := list.(idx)
			sl(idx + 1)
		)
	})(start)
)

` TODO: slice(composite, start, end)
		join(composite, composite) (append)
		-> impl for lists `

` TODO: clone(composite) function`
clone := comp => (
	reduce(keys(comp), (acc, k) => (
		acc.(k) := comp.(k)
		acc
	), {})
)

` tail recursive numeric list -> string converter `
stringList := list => (
	stringListRec := (l, start, acc) => (
		start :: {
			len(l) -> acc
			_ -> stringListRec(
				l
				start + 1
				(acc :: {
					'' -> ''
					_ -> acc + ', '
				}) + string(l.(start))
			)
		}
	)
	'[' + stringListRec(list, 0, '') + ']'
)

` tail recursive reversing a list `
reverse := list => (
	state := [len(list) - 1]
	reduce(list, (acc, item) => (
		acc.(state.0) := item
		state.0 := state.0 - 1
		acc
	), {})
)

` tail recursive map `
map := (list, f) => (
	reduce(list, (l, item) => (
		l.(len(l)) := f(item)
		l
	), {})
)

` tail recursive filter `
filter := (list, f) => (
	reduce(list, (l, item) => (
		f(item) :: {
			true -> l.(len(l)) := item
		}
		l
	), {})
)

` tail recursive reduce `
reduce := (list, f, acc) => (
	(reducesub := (idx, acc) => (
		idx :: {
			len(list) -> acc
			_ -> reducesub(
				idx + 1
				f(acc, list.(idx))
			)
		}
	)
	)(0, acc)
)
