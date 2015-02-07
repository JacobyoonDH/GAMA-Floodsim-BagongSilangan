/**
 *  bsevacuation
 *  Author: geonin
 *  Description: 
 */

model bsevacuation

global {
	/** Insert the global definitions, variables and actions here */
	file building_shp<-file("../includes/bs_buildings_utm.shp");
	file road_shp <- file("../includes/cleaned.shp");
	graph road_network;
	
	
	int nb_people <- 100;

	geometry shape<-envelope(building_shp);		

	init{
		step <-1#s;
		time<-6#h;
		create building from:building_shp with:[my_type::string(read("type"))];
		create road from:road_shp;
		
		create people number:nb_people {
			my_house <- one_of(building where ((each.my_type != 'school') and (each.my_type != 'evacuation')));
			evacuation_center <- one_of(building where (each.my_type='evacuation'));
			location <- my_house.location;
			target <- any_location_in(evacuation_center);
		}
		road_network <- as_edge_graph(road);
	}
	
		reflex end_simulation when:(time = 10#h) {
		do pause;}	
	
}

species building {
	string my_type;
	aspect geom {

		if(self.my_type='school'){
			draw shape color: #blue;}
		else if self.my_type='evacuation'{
			draw shape color: #red;
		}
		else{
			draw shape color: #pink;}
		}
}

species road {
	bool passable <- true;
	aspect geom {
		if (passable = true) {
					draw shape color:#black;			
		}

	}
}

species people skills:[moving] {
	building my_house;
	building evacuation_center;
	float speed <- 5#km/#h;
	point target;
	aspect people_display {
		draw circle(8) color:#yellow;
	}
	
	reflex evacuate when: (time>=6#h)  {
		//target <- any_location_in(evacuation_center);
		do goto target:target on:road_network;
		
		}
	}
	


experiment bsevacuation type: gui {
	/** Insert here the definition of the input and output of the model */
	output {

		display map type: opengl{
			species building aspect:geom;
			species road aspect:geom;
			species people aspect:people_display;
		}
		
	}
}
