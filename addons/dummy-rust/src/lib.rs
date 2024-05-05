use godot::prelude::*;
use rand::Rng;

struct Dummy;

#[gdextension]
unsafe impl ExtensionLibrary for Dummy {}

#[derive(GodotClass)]
#[class(init, base=Object)]
pub struct Dumster {
    base: Base<Object>,
}


#[godot_api]
impl Dumster {
    #[func]
    fn random_vec(&self) -> Array<f64> {
        let mut rng = rand::thread_rng();
        let x: f64 = rng.gen::<f32>() as f64;  // Convert f32 to f64
        let y: f64 = rng.gen::<f32>() as f64;  // Convert f32 to f64
        let mut arr = Array::new();
        arr.push(x);
        arr.push(y);
        arr
    }
}