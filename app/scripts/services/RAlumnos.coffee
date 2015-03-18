angular.module('myvcFrontApp')

.factory('RAlumnos', ['Restangular', (Restangular) ->
	Restangular.service('alumnos')
])


.factory('AlumnosServ', ['Restangular', '$q', (Restangular, $q) ->
	
	alumnos = []

	interfaz = {
		getAlumnos: ()->
			d = $q.defer()

			#console.log 'alumnos.length', alumnos.length
			if alumnos.length > 0
				d.resolve(alumnos)
			else
				Restangular.all('alumnos/sin-matriculas').getList().then((r)->
					alumnos = r
					d.resolve(alumnos)
				, (r2)->
					d.reject(r2)
				)

			return d.promise

			
	}
	return interfaz;
])
