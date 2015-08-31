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

.filter('setDecimal', [ ->
	(input, places)->
		if (isNaN(input)) then return input
		# If we want 1 decimal place, we want to mult/div by 10
		# If we want 2 decimal places, we want to mult/div by 100, etc
		# So use the following to create that factor
		factor = "1" + Array(+(places > 0 and places + 1)).join("0")
		return Math.round(input * factor) / factor

]);
