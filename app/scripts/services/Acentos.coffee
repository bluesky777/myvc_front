angular.module('myvcFrontApp')

.factory('Acentos', ['App', (App) ->

	remove: (texto) ->
		texto = texto
			.toLowerCase()
			.replace(/á/g, 'a')
			.replace(/â/g, 'a')
			.replace(/é/g, 'e')
			.replace(/è/g, 'e')
			.replace(/í/g, 'i')
			.replace(/ì/g, 'i')
			.replace(/ó/g, 'o')
			.replace(/ú/g, 'u')
			.replace(/ü/g, 'u')
			.replace(/ç/g, 'c')

		return texto

	buscarEnGrid: (searchTerm, cellValue, row)->
		@remove = (txt) ->
			txt = txt
				.toLowerCase()
				.replace(/á/g, 'a')
				.replace(/â/g, 'a')
				.replace(/é/g, 'e')
				.replace(/è/g, 'e')
				.replace(/í/g, 'i')
				.replace(/ì/g, 'i')
				.replace(/ó/g, 'o')
				.replace(/ú/g, 'u')
				.replace(/ü/g, 'u')
				.replace(/ç/g, 'c')
			return txt

		texto       = @remove(cellValue)
		search      = @remove(searchTerm)

		return (texto.indexOf(search) != -1)

])
