<?php

/**
 * Interface que debe definirse para todo objeto convertible a JSON.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 27 MAY 2011
 * 
 * @since 1.00
 *
 */
interface TSLJsonAble {

    /**
     * Los implementadores deberan convertir el objeto que 
     * usa esta interfase a formato JSON.
     * 
     * @return string con el objeto convertido a json.
     */
    public function toJSON();
}

?>
