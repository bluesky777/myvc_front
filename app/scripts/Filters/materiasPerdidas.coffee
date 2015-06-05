angular.module('myvcFrontApp')


.filter('materiasPerdidasYear', [ ->
	(alumnos, cant, nota_minima_aceptada) ->

		if cant
		
			@alumnos_response = []

			angular.forEach alumnos, (alumno, key) ->
				
				@cant_asig_perdidas = 0

				angular.forEach alumno.asignaturas, (asignatura, key) ->
					if asignatura.nota_asignatura_year < nota_minima_aceptada
						@cant_asig_perdidas++

				if @cant_asig_perdidas >= cant
					@alumnos_response.push alumno

			return alumnos_response

		else
			return alumnos

		
])


.filter('materiasPerdidas', [ ->
	(alumnos, cant, nota_minima_aceptada) ->
		console.log 'materiasPerdidas', cant, nota_minima_aceptada
		if cant
		
			@alumnos_response = []

			angular.forEach alumnos, (alumno, key) ->
				
				@cant_asig_perdidas = 0

				angular.forEach alumno.asignaturas, (asignatura, key) ->
					if asignatura.nota_asignatura < nota_minima_aceptada
						@cant_asig_perdidas++

				if @cant_asig_perdidas >= cant
					@alumnos_response.push alumno

			return alumnos_response

		else
			return alumnos

		
])
