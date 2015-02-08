/**
 *  bsevacuation
 *  Author: geonin
 *  Description: 
 */

model bsevacuation

global {
	/** Insert the global definitions, variables and actions here */
	int nb_dead_people <- 0 update: people count(each.trapped=true);

	file building_shp<-file("../includes/bs_buildings_utm.shp");
	file road_shp <- file("../includes/cleaned.shp");
	graph road_network;
	
	
	graph from_grid;
	
	file dem_file <- grid_file("../includes/bs_srtm30.asc");
	
	float step <- 1 #minutes;
	float frs <- (0.015) #m / #minutes;
	/**frs-- flood rise speed */
	float ifl <- 12#m update: ifl + (frs * step ) ;	
	
	int nb_people <- 1000;

	geometry shape<-envelope(dem_file);		

	init{
		
		time <- 3 #hours;
		
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
	reflex end_simulation  {
		if (ifl >= 17#m) {
			do pause;
		}
	}	
	
}

grid cell file: dem_file neighbours: 4
{
	float flood_level <- 0.0;
	rgb color <- rgb (int(grid_value /40 * 255),int(grid_value /40 * 255), int(grid_value /40 * 255)); /**update: rgb (0,int((grid_value - flood_level) /120 * 1000), int((flood_level /120) * 1000));*/
	road myroad;
	bool isflooded;
	bool isfloodedn;
	reflex rising{
		if (ifl > grid_value){
			flood_level <- ifl - grid_value;
			if (flood_level > 1.5 #m){
				color <- #maroon;
			}
			else{
				if (flood_level > 0.5 #m){
					color <- #red;
				}
				else{
					if (flood_level > 0.0 #m){
						color <- #yellow;
					}
					
				}
			}
		}
		
	}
	
	reflex floodstatus {
		if (ifl>=grid_value) {
			isflooded <- true;
		}
	}
	reflex neighborstatus {
		list<cell> cellneighbors <- (topology(self) neighbours_of(self)) ;
		list<cell> flooded <- cellneighbors where (each.isflooded=true);
		if not (empty(flooded)) {
			isfloodedn <- true;
			
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
					draw shape color:#gray;			
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
	cell mycell <- first(cell overlapping(self)) update: first(cell overlapping(self));
	bool neighbors_flooded <- false;
	bool roadflooded;
	rgb mycolor <- #lime;
	bool trapped<-false;

	
	
	aspect people_display {
		draw circle(8) color:mycolor;
	}
	
	reflex ispassble {
		
		if (mycell != nil ){
		if (mycell.flood_level > 1){
			trapped <- true;
			mycolor <- #white;
		}
		}
		
	}
	
	reflex floodnear {


	}
	
		
	reflex evacuate when: (mycell.isfloodedn = true)  {
		//target <- any_location_in(evacuation_center);
		do goto target:target on:road_network;
		
		}
		
	
	}
	


experiment bsevacuation type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		monitor "Flood level" value: ifl;
		monitor "Trapped people" value: nb_dead_people;
		display map type: opengl{
	 	 	species cell;			
			species building aspect:geom;
			species road aspect:geom;
			species people aspect:people_display;
						
		}
		
	}
}
