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
module devisualization.scenegraph.base.de_window;
import devisualization.scenegraph.interfaces.scenegraph;
import devisualization.scenegraph.interfaces.elements;

/**
 * Devisualization.Window event support.
 * 
 * Interfaces includes for event controllers.
 * Preffered method and grouping of controllers for a type.
 */
version(Have_de_window_interfaces) {
    import devisualization.window.interfaces.window;
    import devisualization.window.interfaces.events;

    interface SceneGraph2DTypeController : Drawable2DElement {
        void onMouseDown(Element2D, Windowable, MouseButtons, int x, int y);
        void onMouseMove(Element2D, Windowable, int x, int y, bool inArea);
        void onMouseUp(Element2D, Windowable, MouseButtons);
        
        void onKeyDown(Element2D, Windowable, Keys, KeyModifiers);
        void onKeyUp(Element2D, Windowable, Keys, KeyModifiers);
    }
    
    interface SceneGraph3DTypeController : Drawable3DElement {
        void onMouseDown(Element3D, Windowable, MouseButtons, int x, int y);
        void onMouseMove(Element3D, Windowable, int x, int y, bool inArea);
        void onMouseUp(Element3D, Windowable, MouseButtons);
        
        void onKeyDown(Element3D, Windowable, Keys, KeyModifiers);
        void onKeyUp(Element3D, Windowable, Keys, KeyModifiers);
    }

    package {
        import std.string : toUpper;
        import std.algorithm : filter, moveAll;
        
        /**
         * Implements an eventable interface for something.
         * Includes support for bool delegate(T) and void delegate(T).
         * Will consume a call to all delegates if it returns true. Default false.
         * 
         * Example usage:
         *         mixin Eventing!("onNewListing", ListableObject);
         * 
         * If is(T[0] == typeof(this)) then it'll use this as being the first argument. 
         */
        mixin template SceneGraphEventing(string name, T...) {
            private {
                mixin(q{bool delegate(T)[][ulong] } ~ name ~ "_;");
                mixin(q{bool delegate(T)[void delegate(T)][ulong] } ~ name ~ "_assoc;");
            }
            
            mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(ulong type, void delegate(T) value) {
                    mixin(name ~ "_[type] ~= (T args) => {value(args); return false;}();");
                    mixin(name ~ "_assoc[type][value] = " ~ name ~ "_[type][$-1];");
                }});
            mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(ulong type, bool delegate(T) value) {
                    mixin(name ~ "_[type] ~= value;"); 
                }});
            
            mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(ulong type, bool delegate(T) value) {
                    mixin("moveAll(filter!(a => a !is value)(" ~ name ~ "_[type]), " ~ name ~ "_[type]);"); 
                }});
            mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(ulong type, void delegate(T) value) {
                    mixin("moveAll(filter!(a => (value in " ~ name ~ "_assoc[type] && a !is " ~ name ~ "_assoc[type][value]) || (value !in " ~ name ~ "_assoc[type]) )(" ~ name ~ "_[type]), " ~ name ~ "_[type]);"); 
                }});
            
            mixin("size_t count" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(ulong type){
                    return cast(size_t)(mixin(name ~ "_[type].length") + mixin(name ~ "_assoc[type].length")); 
                }});
            
            private {
                mixin("void " ~ name ~ q{(ulong type, T args) {
                        foreach (del; mixin(name ~ "_[type]")) {
                            del(args);
                        }
                    }});
            }
            
            mixin("void clear" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(ulong type, T args) {
                    mixin(name ~ "_[type]") = [];
                }});
        }
    }
}

mixin template DevisualizationWindowSceneGraph() {
	version(Have_de_window_interfaces) {
        import devisualization.window.interfaces.window;
        import devisualization.window.interfaces.events;

        private {
            Windowable window_;
        }
        
        @property {
            Windowable window() {
                return window_;
            }
        }
        
        void register(T)(ushort type, T controller) if (is(T : SceneGraph2DTypeController) && is(T : SceneGraph3DTypeController)) {
            register(type, cast(SceneGraph2DTypeController)controller);
            register(type, cast(SceneGraph3DTypeController)controller);
        }
        
        void register(T : SceneGraph2DTypeController)(ushort type, T controller) {
            registerDrawer(&controller.draw, type);
            
            addOnMouseDown2D(type, &controller.onMouseDown);
            addOnMouseMove2D(type, &controller.onMouseMove);
            addOnMouseUp2D(type, &controller.onMouseUp);
            
            addOnKeyDown2D(type, &controller.onKeyDown);
            addOnKeyUp2D(type, &controller.onKeyUp);
        }
        
        void register(T : SceneGraph3DTypeController)(ushort type, T controller) {
            registerDrawer(&controller.draw, type);
            
            addOnMouseDown3D(type, &controller.onMouseDown);
            addOnMouseMove3D(type, &controller.onMouseMove);
            addOnMouseUp3D(type, &controller.onMouseUp);
            
            addOnKeyDown3D(type, &controller.onKeyDown);
            addOnKeyUp3D(type, &controller.onKeyUp);
        }
        
        /*
         * Mouse 
         */
        void onMouseDown(MouseButtons buttons, int x, int y) {
            void e2d(Element2D e) {
                if (e.x >= x && e.y >= y && e.x + e.width < x && e.y + e.height < y)
                    onMouseDown2D(e.type, e, window_, buttons, x, y);
            }
            root_2d.apply(&e2d);
            
            // should really check z axis, but how can I?
            // only events the first hit aka the closest to the top
            bool e3d(Element3D e) {
                if (e.x >= x && e.y >= y && e.x + e.width < x && e.y + e.height < y) {
                    onMouseDown3D(e.type, e, window_, buttons, x, y);
                    return true;
                }
                
                return false;
            }
            root_3d.apply(&e3d);
        }
        
        void onMouseMove(int x, int y) {
            void e2d(Element2D e) {
                onMouseMove2D(e.type, e, window_, x, y, e.x >= x && e.y >= y && e.x + e.width < x && e.y + e.height < y);
            }
            root_2d.apply(&e2d);
            
            void e3d(Element3D e) {
                onMouseMove3D(e.type, e, window_, x, y, e.x >= x && e.y >= y && e.x + e.width < x && e.y + e.height < y);
            }
            root_3d.apply(&e3d);
        }
        
        void onMouseUp(MouseButtons buttons) {
            void e2d(Element2D e) {
                onMouseUp2D(e.type, e, window_, buttons);
            }
            root_2d.apply(&e2d);
            
            void e3d(Element3D e) {
                onMouseUp3D(e.type, e, window_, buttons);
            }
            root_3d.apply(&e3d);
        }
        
        mixin SceneGraphEventing!("onMouseDown2D", Element2D, Windowable, MouseButtons, int, int);
        mixin SceneGraphEventing!("onMouseMove2D", Element2D, Windowable, int, int, bool); // last bool = is moved in area
        mixin SceneGraphEventing!("onMouseUp2D", Element2D, Windowable, MouseButtons);
        
        mixin SceneGraphEventing!("onMouseDown3D", Element3D, Windowable, MouseButtons, int, int);
        mixin SceneGraphEventing!("onMouseMove3D", Element3D, Windowable, int, int, bool); // last bool = is moved in area
        mixin SceneGraphEventing!("onMouseUp3D", Element3D, Windowable, MouseButtons);
        
        /*
         * Keyboard
         * KeyModifiers is an or'd mask or modifiers upon the key
         */
        
        void onKeyDown(Keys keys, KeyModifiers mods) {
            void e2d(Element2D e) {
                onKeyDown2D(e.type, e, window_, keys, mods);
            }
            root_2d.apply(&e2d);
            
            void e3d(Element3D e) {
                onKeyDown3D(e.type, e, window_, keys, mods);
            }
            root_3d.apply(&e3d);
        }
        
        void onKeyUp(Keys keys, KeyModifiers mods) {
            void e2d(Element2D e) {
                onKeyUp2D(e.type, e, window_, keys, mods);
            }
            root_2d.apply(&e2d);
            
            void e3d(Element3D e) {
                onKeyUp3D(e.type, e, window_, keys, mods);
            }
            root_3d.apply(&e3d);
        }
        
        mixin SceneGraphEventing!("onKeyDown2D", Element2D, Windowable, Keys, KeyModifiers);
        mixin SceneGraphEventing!("onKeyUp2D", Element2D, Windowable, Keys, KeyModifiers);
        
        mixin SceneGraphEventing!("onKeyDown3D", Element3D, Windowable, Keys, KeyModifiers);
        mixin SceneGraphEventing!("onKeyUp3D", Element3D, Windowable, Keys, KeyModifiers);
    }
}