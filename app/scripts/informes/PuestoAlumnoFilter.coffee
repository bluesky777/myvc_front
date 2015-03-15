angular.module("myvcFrontApp")

.filter('puestoAlumno', [ ->
	(alumno, alumnos)->

		puesto = 0

		angular.forEach alumnos, (alum)->
			if alumno.promedio < alum.promedio
				puesto = puesto + 1

		return puesto
])

