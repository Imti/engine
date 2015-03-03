#pragma glslify: convertToClipSpace = require(./chunks/convertToClipSpace)
#pragma glslify: getNormalMatrix = require(./chunks/getNormalMatrix)
#pragma glslify: invertYAxis = require(./chunks/invertYAxis)
#pragma glslify: inverse = require(./chunks/inverse)
#pragma glslify: transpose = require(./chunks/transpose)

vec4 applyTransform(vec4 pos) {
   mat4 projection = perspective;
   mat4 MVMatrix = invertYAxis(transform);
   vec4 translation = MVMatrix[3];
   MVMatrix[3] = vec4(0.0, 0.0, 0.0, 1.0);
   
   pos.xyz *= size.xyz;
   pos.y *= -1.0;
   vec4 pixelPosition = vec4(pos.x * 0.5, pos.y * 0.5, pos.z * 0.5, 1.0);
   mat4 pixelTransform = transform;
   pixelTransform[3][0] += size.x * 0.5;
   pixelTransform[3][1] += size.y * 0.5;

   projection[0][0] = 1.0/resolution.x;
   projection[1][1] = 1.0/resolution.y;
   projection[2][2] = (resolution.y > resolution.x) ? -1.0/resolution.y : -1.0/resolution.x;


   vPosition = (pixelTransform * pixelPosition).xyz;

   pos = projection * MVMatrix * pos;

   pos += convertToClipSpace(translation);

   return pos;
}

// Main function of the vertex shader.  Passes texture coordinat
// and normal attributes as varyings and passes the position
// attribute through position pipeline
void main() {
   gl_PointSize = 10.0;
   vec3 invertedNormals = normals;
   invertedNormals.y *= -1.0;
   vNormal = transpose(mat3(inverse(transform))) * invertedNormals;
   vTextureCoordinate = texCoord;
   gl_Position = applyTransform(vec4(pos, 1.0));
}
