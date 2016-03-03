angular.module('myvcFrontApp')


.factory('YearsServ', ['Restangular', '$q', (Restangular, $q) ->
	
	years = []

	interfaz = {
		getYears: ()->
			d = $q.defer()

			#console.log 'years.length', years.length
			if years.length > 0
				d.resolve(years)
			else
				Restangular.one('years').getList().then((r)->
					years = r
					d.resolve(years)
				, (r2)->
					d.reject(r2)
				)

			return d.promise

			
	}
	return interfaz;
])
