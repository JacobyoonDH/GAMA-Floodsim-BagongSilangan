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
	
	graph from_grid;
	
	file dem_file <- grid_file("../includes/bs_srtm30.asc");
	
	float frs <- 1 #m/#h;
	/**frs-- flood rise speed */
	float ifl <- 9#m update: ifl + frs ;	
	
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
		road_network <- as_edge_graph(road where (each.passable = true));
		//from_grid <- grid_cells_to_graph(cell);
	}
/* 
	reflex updateroads {
	//	road_network <- as_edge_graph(road where (each.passable = true));		
	}	
*/	
	reflex end_simulation when:(time = 10#h) {
		do pause;}	
	
}

grid cell file: dem_file neighbours: 4
{
	float flood_level <- 0.0;
	rgb color <- rgb (0,int(grid_value /120 * 1000), 0) update: rgb (0,int((grid_value - flood_level) /120 * 1000), int((flood_level /120) * 1000));
	road myroad;
	bool isflooded;
	
	reflex rising{
		if (ifl > grid_value){
			flood_level <- ifl - grid_value;
		}
		
	}
	
	reflex floodstatus {
		if (ifl>=grid_value) {
			isflooded <- true;
		}
	}
	
	
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
	
	reflex updatestatus {

	}		
}

species people skills:[moving] {
	building my_house;
	building evacuation_center;
	float speed <- 5#km/#h;
	point target;
	cell mycell;
	bool roadflooded;
	
	
	aspect people_display {
		draw circle(8) color:#yellow;
	}
	
	reflex ispassble {
		
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
	 	 	species cell;			
			species building aspect:geom;
			species road aspect:geom;
			species people aspect:people_display;
						
		}
		
	}
}
