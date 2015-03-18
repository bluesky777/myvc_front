angular.module("myvcFrontApp")

.filter('puestoAlumno', [ ->
	(alumno, alumnos)->

		puesto = 0

		angular.forEach alumnos, (alum)->
			if alumno.promedio < alum.promedio
				puesto = puesto + 1

		return puesto
])


.filter('notasAsignatura', [ ->
	(unidades)->

		echo = ''

		angular.forEach unidades, (unidad)->
			echo = echo + '<b class="unidad-pop">' + unidad.definicion_unidad + '</b><br>'

			angular.forEach unidad.subunidades, (subunidad, key) ->
				echo = echo + (key + 1) + '. ' + subunidad.definicion_subunidad + ' - <b>' + subunidad.nota.nota + '</b><br>'

		return echo
])


.filter('notasPerdidasAsignatura', ['Perfil', (Perfil)->
	(unidades, cantidad)->

		unidades_response = []
		cantidad_perdidas = 0

		angular.forEach unidades, (unidad) ->

			subunis = []

			angular.forEach unidad.subunidades, (subunidad) ->
				if subunidad.nota.nota < Perfil.User().nota_minima_aceptada
					subunis.push subunidad
					cantidad_perdidas = cantidad_perdidas + 1
				console.log 'Recorriendo cantidad_perdidas', cantidad_perdidas

			console.log 'Recorriendo en unidades, ', cantidad_perdidas

			if subunis.length > 0
				unidades_response.push unidad


		if cantidad
			console.log 'Al final es ', cantidad_perdidas
			return cantidad_perdidas


		echo = ''

		angular.forEach unidades_response, (unidad)->
			echo = echo + '<b class="unidad-pop">' + unidad.definicion_unidad + '</b><br>'

			angular.forEach unidad.subunidades, (subunidad, key) ->
				echo = echo + (key + 1) + '. ' + subunidad.definicion_subunidad + ' - <b>' + subunidad.nota.nota + '</b><br>'

		
		return echo
])

