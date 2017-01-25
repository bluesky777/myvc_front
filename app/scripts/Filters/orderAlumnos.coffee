angular.module('myvcFrontApp')



.filter('orderMatriculadosBy', [ ->
	(items, dato) ->

		filtered = [];
		angular.forEach(items, (item)->
			filtered.push(item);
		)

		sortTiempo = (a, b)->
			if a.resultados.tiempo > b.resultados.tiempo
				return if reverse then 1 else -1
			else if a.resultados.tiempo == b.resultados.tiempo
				return 0
			else
				return if reverse then -1 else 1

		filtered.sort( (a, b)->
			switch tipo 
				when 'promedio'
					if a.resultados.promedio > b.resultados.promedio
						return if reverse then -1 else 1
					else if a.resultados.promedio == b.resultados.promedio
						return sortTiempo(a, b)
					else
						return if reverse then 1 else -1
						
				when 'cantidad_pregs'
					if a.resultados.cantidad_pregs > b.resultados.cantidad_pregs
						return if reverse then -1 else 1
					else if a.resultados.cantidad_pregs == b.resultados.cantidad_pregs
						return sortTiempo(a, b)
					else
						return if reverse then 1 else -1

				when 'nombres', 'examen_id', 'categorias', 'examen_at'
					if a[tipo] > b[tipo]
						return if reverse then -1 else 1
					else if a[tipo] == b[tipo]
						return sortTiempo(a, b)
					else
						return if reverse then 1 else -1

				when 'tiempo'
					return sortTiempo(a, b)

		);

		return filtered;
])


