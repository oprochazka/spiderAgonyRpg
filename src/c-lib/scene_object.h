//
// Created by ondrej on 4.2.18.
//

#ifndef C_LIB_SCENE_OBJECT_H
#define C_LIB_SCENE_OBJECT_H

typedef struct ERPG_Scene_object {
	int id;
	const char * type;
	void * value;
} ERPG_Scene_object;

#endif //C_LIB_SCENE_OBJECT_H
