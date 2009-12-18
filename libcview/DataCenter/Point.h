#ifndef POINT_H
#define POINT_H

typedef struct {
    int x,y,z;
} Point;

typedef struct
{
    float tu, tv;
    float x, y, z;
} Vertex;
typedef struct {
    Vertex *verts;
    int vertCount;
} VertArray;

#endif