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
			echo = echo + '<div class="ellipsis350"><b>' + unidad.definicion_unidad + '</b></div>'

			angular.forEach unidad.subunidades, (subunidad, key) ->
				echo = echo + (key + 1) + '. ' + subunidad.definicion_subunidad + '<b> => ' + subunidad.nota.nota + '</b><br>'

		return echo
])


.filter('notasPerdidasAsignatura', ['Perfil', (Perfil)->
	(unidades, cantidad)->

		@unidades_response = []
		@cantidad_perdidas = 0

		angular.forEach(unidades, (unidad) ->

			@subunis = []

			angular.forEach(unidad.subunidades, (subunidad) ->

				if subunidad.nota.nota
				
					if subunidad.nota.nota < Perfil.User().nota_minima_aceptada
						@subunis.push subunidad

				else

					if subunidad.nota < Perfil.User().nota_minima_aceptada
						@subunis.push subunidad

			, @)
			
			@cantidad_perdidas = @cantidad_perdidas + @subunis.length

			if @subunis.length > 0

				newUni = 
					unidad_id: 			unidad.unidad_id
					definicion_unidad: 	unidad.definicion_unidad
					valor_unidad: 		unidad.valor_unidad
					orden_unidad: 		unidad.orden_unidad
					nota_unidad: 		unidad.nota_unidad
					subunidades: 		@subunis

				@unidades_response.push newUni
		, @)


		if cantidad
			return @cantidad_perdidas


		echo = ''

		angular.forEach unidades_response, (unidad)->
			echo = echo + '<div class="ellipsis350"><b>' + unidad.definicion_unidad + '</b></div>'

			angular.forEach unidad.subunidades, (subunidad, key) ->
				echo = echo + '<span class="ellipsis250">' + (key + 1) + '. ' + subunidad.definicion_subunidad + ' </span><b> => ' + subunidad.nota.nota + '</b><br>'

		
		return echo
])

.filter('notasPerdidasAsignaturaPeriodo', ['Perfil', '$filter', (Perfil, $filter)->
	(asignaturas, cantidad)->

		total = 0
		for asignatura in asignaturas
			uniPerdidas = $filter('notasPerdidasAsignatura')(asignatura.unidades, true)
			total = total + uniPerdidas
		


		return total

])

