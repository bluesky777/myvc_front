angular.module("myvcFrontApp")


.filter('promGrupoYear', [ ->
	(alumnos)->

		promedio = 0

		for alumno in alumnos
			promedio = promedio + alumno.promedio_year


		return (promedio/alumnos.length)

])



.filter('promAsigYear', ['$filter', ($filter)->
	(alumnos, asignatura_id)->

		promedioAsig = 0
		cant = 0

		for alumno in alumnos
			for asignatura in alumno.asignaturas

				if asignatura.asignatura_id == asignatura_id
					cant++
					promedioAsig = promedioAsig + asignatura.nota_asignatura_year
		


		return (promedioAsig/cant)

])


.filter('notasAsignaturaYear', ['$filter', ($filter)->
	(periodos)->

		cantPerd = 0
		echo = ''

		for periodo in periodos
			echo = echo + $filter('notasAsignatura')(periodo.unidades, periodo.numero)
			
		
		return echo
])


.filter('notasPerdidasAsignaturaYear', ['$filter', ($filter)->
	(periodos, cantidad)->

		cantPerd = 0
		echo = ''

		for periodo in periodos
			if cantidad
				cantPerd = cantPerd + $filter('notasPerdidasAsignatura')(periodo.unidades, cantidad, periodo.numero)
			else
				echo = echo + $filter('notasPerdidasAsignatura')(periodo.unidades, false, periodo.numero)
			
		
		if cantidad
			return cantPerd
		else
			return echo

		
		
])

.filter('notasPerdidasAsignaturasYear', ['$filter', ($filter)->
	(asignaturas)->

		@cantidad_perdidas = 0

		angular.forEach asignaturas, (asignatura) ->
			@cantidad_perdidas = @cantidad_perdidas + $filter('notasPerdidasAsignaturaYear')(asignatura.periodos, true)

		return @cantidad_perdidas
])

.filter('notasPerdidasGrupoYear', ['$filter', ($filter)->
	(alumnos)->

		cant = 0

		for alumno in alumnos
			cant = cant + $filter('notasPerdidasAsignaturasYear')(alumno.asignaturas, true)


		return cant

])



