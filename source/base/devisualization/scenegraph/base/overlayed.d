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
module devisualization.scenegraph.base.overlayed;
import devisualization.scenegraph.base.de_window;
import devisualization.scenegraph.interfaces.scenegraph;
import devisualization.scenegraph.interfaces.elements;

/**
 * Implements a 3d scenegraph with a 2d overlayed one on top.
 * Optionally will also include support for Devisualization.Window events.
 */
class SceneGraph3DOverlayed2D : SceneGraph3D, SceneGraph2D {
    Element2D root_2d;
    Element3D root_3d;
    
    private {
        void delegate(Element2D)[ulong] drawers_2d;
        void delegate(Element3D)[ulong] drawers_3d;
    }
    
    this() {
        root_2d = new Element2D(Element.init, 0, 0, 0, 0);
        root_3d = new Element3D(Element.init, 0, 0, 0, 0, 0, 0);
        
        drawers_2d[UNKNOWN_DRAWER] = (Element2D element) {
            // unknown type
        };
        
        drawers_3d[UNKNOWN_DRAWER] = (Element3D element) {
            // unknown type
        };
        
        clearBuffers_ = () {};
    }
    
    void add(Element2D element) {
        root_2d.elements ~= element;
    }
    
    void remove(Element2D element) {
        bool r(Element2D container) {
            foreach(i, e; container.elements) {
                if (e.type == element.type && e.idHash == element.idHash) {
                    if (container.elements.length > i + 1 && i > 0)
                        container.elements = container.elements[0 .. i] ~ container.elements[i + 1 .. $];
                    else if (container.elements.length > i + 1 && i == 0)
                        container.elements = container.elements[1 .. $];
                    else if (container.elements.length == i + 1 && i != 0)
                        container.elements = container.elements[0 .. $-1];
                    else
                        container.elements = null;
                    
                    return true;
                }
            }
            return false;
        }
        
        root_2d.apply(&r);
    }
    
    void add(Element3D element) {
        root_3d.elements ~= element;
    }
    
    void remove(Element3D element) {
        bool r(Element3D container) {            
            foreach(i, e; container.elements) {
                if (e.type == element.type && e.idHash == element.idHash) {
                    if (container.elements.length > i + 1 && i > 0)
                        container.elements = container.elements[0 .. i] ~ container.elements[i + 1 .. $];
                    else if (container.elements.length > i + 1 && i == 0)
                        container.elements = container.elements[1 .. $];
                    else if (container.elements.length == i + 1 && i != 0)
                        container.elements = container.elements[0 .. $-1];
                    else
                        container.elements = null;
                    
                    return true;
                }
            }
            return false;
        }
        
        root_3d.apply(&r);
    }
    
    void draw() {
        //iterate over root_3d
        void d3d(Element3D e) {
            // draw e
            drawers_3d.get(e.type, drawers_3d[UNKNOWN_DRAWER])(e);
        }
        root_3d.apply(&d3d);
        //draw from it
        
        //clear depth buffers
        clearBuffers_();
        
        //iterate over root_2d
        void d2d(Element2D e) {
            // draw e
            drawers_2d.get(e.type, drawers_2d[UNKNOWN_DRAWER])(e);
        }
        root_2d.apply(&d2d);
        //draw from it
    }
    
    void register(ushort type, void delegate(Element2D) drawer) {
        drawers_2d[type] = drawer;
    }

    void register(ushort type, void delegate(Element3D) drawer) {
        drawers_3d[type] = drawer;
    }

    void register(T)(ushort type, T controller) if (is(T : Drawable2DElement) && is(T : Drawable3DElement)) {
        register(type, cast(Drawable2DElement)controller);
        register(type, cast(Drawable3DElement)controller);
    }
    
    void register(T : Drawable2DElement)(ushort type, T controller) {
        register(&controller.draw, type);
    }
    
    void register(T : Drawable3DElement)(ushort type, T controller) {
        register(&controller.draw, type);
    }
    
    void updateIdHashes() {
        void u2d(Element2D e) {
            e.updateHashId(root_2d);
        }
        root_2d.apply(&u2d);
        
        void u3d(Element3D e) {
            e.updateHashId(root_3d);
        }
        root_3d.apply(&u3d);
    }
    
    override string toString() {
        string ret = "2D: [\n";
        
        size_t pIndent;
        void c2d(Element2D e, uint indent) {
            import std.conv : text;
            
            string sIndent;
            foreach(i; 0 .. indent) {
                sIndent ~= "    ";
            }
            
            if (pIndent < indent) {
                ret ~= sIndent ~ "[\n";
            } else if (pIndent > indent) {
                ret.length -= 2;
                ret ~= "\n" ~ sIndent ~ "]\n";
            }
            
            ret ~= sIndent ~ " { type   = " ~ text(e.type) ~ "\n" ~
                sIndent ~ "   id     = " ~ text(e.idHash) ~ "\n" ~
                    sIndent ~ "   x      = " ~ text(e.x) ~ "\n" ~
                    sIndent ~ "   y      = " ~ text(e.y) ~ "\n" ~
                    sIndent ~ "   width  = " ~ text(e.width) ~ "\n" ~
                    sIndent ~ "   height = " ~ text(e.height) ~ " },\n";
            
            pIndent = indent;
        }
        
        root_2d.apply(&c2d);
        
        if (pIndent > 0) {
            string sIndent;
            foreach(i; 0 .. pIndent) {
                sIndent ~= "    ";
            }
            
            ret.length -= 2;
            ret ~= "\n" ~ sIndent ~ "]\n";
        }
        
        ret ~= "]\n";
        ret ~= "3D: [\n";
        
        pIndent = 0;
        void c3d(Element3D e, uint indent) {
            import std.conv : text;
            
            string sIndent;
            foreach(i; 0 .. indent) {
                sIndent ~= "    ";
            }
            
            if (pIndent < indent) {
                ret ~= sIndent ~ "[\n";
            } else if (pIndent > indent) {
                ret.length -= 2;
                ret ~= "\n" ~ sIndent ~ "]\n";
            }
            
            ret ~= sIndent ~ " { type   = " ~ text(e.type) ~ "\n" ~
                sIndent ~ "   id     = " ~ text(e.idHash) ~ "\n" ~
                    sIndent ~ "   x      = " ~ text(e.x) ~ "\n" ~
                    sIndent ~ "   y      = " ~ text(e.y) ~ "\n" ~
                    sIndent ~ "   z      = " ~ text(e.z) ~ "\n" ~
                    sIndent ~ "   width  = " ~ text(e.width) ~ "\n" ~
                    sIndent ~ "   height = " ~ text(e.height) ~ "\n" ~
                    sIndent ~ "   depth  = " ~ text(e.depth) ~ " },\n";
            
            pIndent = indent;
        }
        
        root_3d.apply(&c3d);
        
        if (pIndent > 0) {
            string sIndent;
            foreach(i; 0 .. pIndent) {
                sIndent ~= "    ";
            }
            
            ret.length -= 2;
            ret ~= "\n" ~ sIndent ~ "]\n";
        }
        
        ret ~= "]\n";
        
        return ret;
    }
    
    private {
        void delegate() clearBuffers_;
    }
    
    @property {
        void clearBuffers(void delegate() f) {
            clearBuffers_ = f;
        }
    }

	// basically this should be in the mixin but it appears to be a bug where it won't work.
	version(Have_de_window_interfaces) {
		import devisualization.window.interfaces.window;

		this(Windowable window) {
			this();
			window_ = window;
			
			window.addOnMouseDown((Windowable, MouseButtons buttons, int x, int y) {
				onMouseDown(buttons, x, y);
			});
			
			window.addOnMouseMove((Windowable, int x, int y) {
				onMouseMove(x, y);
			});
			
			window.addOnMouseUp((Windowable, MouseButtons buttons) {
				onMouseUp(buttons);
			});
			
			window.addOnKeyDown((Windowable, Keys keys, KeyModifiers mods) {
				onKeyDown(keys, mods);
			});
			
			window.addOnKeyUp((Windowable, Keys keys, KeyModifiers mods) {
				onKeyUp(keys, mods);
			});
		}

	    mixin DevisualizationWindowSceneGraph;
	}
}