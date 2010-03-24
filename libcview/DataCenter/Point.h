#ifndef POINT_H
#define POINT_H

typedef struct {
    float x,y,z;
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
typedef struct
{
    float x,y,z;
}V3F;
#endif
