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
	(unidades, num_periodo)->

		echo = ''

		angular.forEach unidades, (unidad)->
			echo = echo + '<div class="ellipsis350"><b>Per' + num_periodo + ': ' + unidad.definicion_unidad + '</b></div>'

			angular.forEach unidad.subunidades, (subunidad, key) ->
				if subunidad.nota
					echo = echo + (key + 1) + '. ' + subunidad.definicion_subunidad + '<b> => ' + subunidad.nota.nota + '</b><br>'

		return echo
])


.filter('notasPerdidasAsignaturas', ['$filter', ($filter)->
	(asignaturas)->

		@cantidad_perdidas = 0

		angular.forEach asignaturas, (asignatura) ->
			@cantidad_perdidas = @cantidad_perdidas + $filter('notasPerdidasAsignatura')(asignatura.unidades, true)

		return @cantidad_perdidas
])

.filter('notasPerdidasAsignatura', ['Perfil', (Perfil)->
	(unidades, cantidad, num_periodo)->

		@unidades_response = []
		@cantidad_perdidas = 0

		angular.forEach(unidades, (unidad) ->

			@subunis = []

			angular.forEach(unidad.subunidades, (subunidad) ->

				if subunidad.nota
					if subunidad.nota.nota or subunidad.nota.nota == 0
					
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
			echo = echo + '<div class="ellipsis350"><b>Per' + num_periodo + ': ' + unidad.definicion_unidad + '</b></div>'

			angular.forEach unidad.subunidades, (subunidad, key) ->
				echo = echo + '<span class="ellipsis250">' + (key + 1) + '. ' + subunidad.definicion_subunidad + ' </span><b> => ' + subunidad.nota.nota + '</b><br>'

		
		return echo
])

.filter('notasPerdidasAsignaturaPeriodo', ['$filter', ($filter)->
	(asignaturas, cantidad)->

		total = 0
		for asignatura in asignaturas
			uniPerdidas = $filter('notasPerdidasAsignatura')(asignatura.unidades, true)
			total = total + uniPerdidas
		


		return total

])

.filter('promAsig', ['$filter', ($filter)->
	(alumnos, asignatura_id)->

		promedioAsig = 0
		cant = 0

		for alumno in alumnos
			for asignatura in alumno.asignaturas

				if asignatura.asignatura_id == asignatura_id
					cant++
					promedioAsig = promedioAsig + asignatura.nota_asignatura
		


		return (promedioAsig/cant)

])


.filter('promGrupoPer', ['$filter', ($filter)->
	(alumnos)->

		promedio = 0

		for alumno in alumnos
			promedio = promedio + alumno.promedio


		return (promedio/alumnos.length)

])

.filter('notasPerdidasGrupoPer', ['$filter', ($filter)->
	(alumnos)->

		cant = 0

		for alumno in alumnos
			cant = cant + $filter('notasPerdidasAsignaturaPeriodo')(alumno.asignaturas, true)



		return cant

])

