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

.filter('decimales_if', [ ->
	(input, cant) ->
		input = parseFloat(input)

		if (input % 1) == 0
			input = input.toFixed(0)
		else
			input = input.toFixed(cant)

		numero = input.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
		numero = parseFloat(numero)
		return numero
])

.filter('setDecimal', [ ->
	(input, places)->
		if (isNaN(input)) then return input
		# If we want 1 decimal place, we want to mult/div by 10
		# If we want 2 decimal places, we want to mult/div by 100, etc
		# So use the following to create that factor
		factor = "1" + Array(+(places > 0 and places + 1)).join("0")
		return Math.round(input * factor) / factor

])

.filter('formatNumberDocumento', ['$filter', ($filter)->
	(input)->
		if (!isNaN(input) && angular.isNumber(+input))
			return $filter('number')(input, 0)
		else
			return input

]);
