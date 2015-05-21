angular.module('myvcFrontApp')

.factory('RYears', ['Restangular', (Restangular) ->
	Restangular.service('years')
])

.factory('RPeriodos', ['Restangular', (Restangular) ->
	Restangular.service('periodos')
])



.factory('YearsServ', ['RYears', '$q', (RYears, $q) ->
	
	years = []

	interfaz = {
		getYears: ()->
			d = $q.defer()

			#console.log 'years.length', years.length
			if years.length > 0
				d.resolve(years)
			else
				RYears.getList().then((r)->
					years = r
					d.resolve(years)
				, (r2)->
					d.reject(r2)
				)

			return d.promise

			
	}
	return interfaz;
])
