# HackerBooks

## English

**PDF book reader for iPhone &amp; iPad coded in Swift 2.2. This is a practice of iOS course (Keepcoding)**

## Español

**Lector de libros PDF para iPhone y iPad codificado en Swift 2.2. Una práctica del curso de iOS (Keepcoding)** 

### ¿Como funciona?

La aplicación cuando se inicia intenta obtener el JSON con la información de los libros. La aplicación usa un metodo generico para obtener todos los recursos desde internet, este método comprueba si el recurso existe en local en la carpeta Cache, si tiene el recurso lo servirá directamente, sino lo descargará desde el servidor. 

La aplicación una vez tenga el JSON del servidor lo convertirá al modelo y la información de este será visible en un formato de lista el cual puede mostrar todos los libros ordenados o mostrarlos por temáticas.

Los libros son posibles marcalos como favoritos, estos serán persistentes y se guardaran gracias a la clase NSUserDefaults.

La aplicación implementa GCD en los recursos como las imagenes y PDF, se muestra un activityIndicator mientras se obtienen alguno de estos recursos. Solo se descargaran estos recursos si la interfaz lo requiere. Una prueba de ello es realizar scroll en la lista de libros. Podrá ver como las imagenes cargan cuando aparecen libros nuevos en la pantalla.

### Preguntas de la práctica

#### Mirar en la ayuda isKindOfClass, ¿en que modos podemos trabajar? is, as?

La clase isKindOfClass sirbe para saber si una determinada clase es de un tipo determinado. Durante la practica trabajo en varias ocasiones con el operador 'as', dicho operador es para realizar casting.

#### ¿donde guardas las imagenes de portada y los PDF?

Dentro de la sandbox en la carpeta de Cache. Estos recursos pueden ser descargados del servidor siempre y si el sistema necesita espacio pueden ser eliminados sin problema alguno.

#### ¿Como guardar los favoritos? ¿Formas de hacerlo?

Pues actualmente y con los conocimientos actuales se puede usar NSUserDefaults o escribir los favoritos en un archivo y guardarlo dentro de la carpeta Documents de la Sandbox. Más adelante, se podría usar CoreData para guardar los libros y ya se incluiría esta propiedad tambien.

Yo he optado por la forma más sencilla y he usado NSUserDefault. Para cada libro uso como Key su nombre de archivo y voy almacenando un valor boleano. Es una solución demasiado sencila y limitada, pero para este ejemplo sobra.

#### ¿Cómo harías para notificar que la propiedad isFavorite de un libro ha cambiado? ¿Formas de hacerlo?

Se podría realizar mediante target->Action, delegado o notificaciones. En el caso de la práctica, he decidido realizarlo haciendo uso de las notificaciones.

#### Sobre el método reloadData, ¿es esto una aberración en el rendimiento? ¿Hay una forma alternativa? ¿Cuando crees que vale la pena usarlo?

Al rendimiento afecta, pero no creo que sea una aberración. iOS solo va a recargar las celdas visibles en la pantalla y no todas las celdas puesto que las reaprochecha.

Supongo que TableViewController implementará algún metodo para poder modificar la tabla sin tener que realizar un reload. Valdrá la pena usarlo cuando las celdas tengan muchas propiedades o cargen mucha información.

#### Cuando el usuario cambia en la tabla el libro seleccionado, el SimplePDFViewController debe actualizase. ¿Como lo harias?

Mediante el uso de las notificaciones. El controlador SimplePDFViewController se suscribirá a las notificaciones cuando esté en pantalla y se dessuscribirá cuando desaparezca. Cuando un libro es pulsado en la tabla se manda la notificación y si está el SimplePDFViewController este actualiza su modelo y recarga el webView.
