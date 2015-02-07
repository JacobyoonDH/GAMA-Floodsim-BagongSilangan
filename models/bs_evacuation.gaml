/**
 *  bsevacuation
 *  Author: geonin
 *  Description: 
 */

model bsevacuation

global {
	/** Insert the global definitions, variables and actions here */
	file building_shp<-file("../includes/bs_buildings_utm.shp");
	file ec_shp <- file("../includes/bs_ec_utm.shp");
	
	int nb_people <- 100;

	geometry shape<-envelope(building_shp);		

	init{
		step <-1#mn;
		time<-6#h;
		create building from:building_shp with:[my_type::string(read("type"))];
		
		create people number:nb_people {
			my_house <- one_of(building where (each.my_type != 'school'));
		}
	}
	
}

species building {
	string my_type;
	aspect geom {

		if(self.my_type='school'){
			draw shape color: #blue;}
		if self.my_type='evacuation'{
			draw shape color: #red;
		}
		else{
			draw shape color: #pink;}
		}
}

species people {
	building my_house;
	aspect people_display {
		draw circle(8) color:#yellow;
	}
}	


experiment bsevacuation type: gui {
	/** Insert here the definition of the input and output of the model */
	output {

		display map type: opengl{
			species building aspect:geom refresh:false;
			species people aspect:people_display refresh:false;
		}
		
	}
}
