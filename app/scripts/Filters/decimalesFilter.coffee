angular.module('myvcFrontApp')

.filter('decimales', [ ->
	(input, cant) ->
		input = parseFloat(input)

		if (input % 1) == 0
			input = input.toFixed(0)
		else 
			input = input.toFixed(cant)

		return input.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
])
