/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Devisualization (Richard Andrew Cattermole)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module devisualization.scenegraph.interfaces.scenegraph;
import devisualization.scenegraph.interfaces.elements;

enum ulong UNKNOWN_DRAWER = 0;

interface SceneGraph {
    void updateIdHashes();
    void draw();
}

interface SceneGraph2D : SceneGraph {
    void add(Element2D element);
    void remove(Element2D element);

    void register(ushort type, void delegate(Element2D) drawer);
    void register(T : Drawable2DElement)(ushort type, T controller);
}

interface SceneGraph3D : SceneGraph {
    void add(Element3D element);
    void remove(Element3D element);

    void register(ushort type, void delegate(Element3D) drawer);
    void register(T : Drawable3DElement)(ushort type, T controller);
}

/**
 * For user code:
 * 
 * Extend this to support your own drawer for a type
 */

interface Drawable2DElement {
    void draw(Element2D);
}

interface Drawable3DElement {
    void draw(Element3D);
}