<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * TSL framework helper que carga un especifico DAO
 * para una determinada base de datos.
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLUtilsHelper {

    private static $defaultDbDriver = NULL;
    private static $defaultDb = NULL;

    /**
     * Busca en la definicion de la base de datos (database.php)
     * si se ha definido una default , de ser asi retorna el driver
     * que la maneja.
     *
     * @return string el driver default o null
     */
    public static function getDefaultDatabaseDriver() {
        if (!isset(self::$defaultDbDriver)) {
            require (APPPATH . '/config/database.php');
            // Si se ha definido el active_group
            // o base de datos default y asi mismo se ha definido que driver usas la misma , se
            // retorna su valor , de lo contrario null
            if (isset($active_group) and empty($active_group) == FALSE and
                    isset($db[$active_group]['dbdriver'])) {
                self::$defaultDbDriver = $db[$active_group]['dbdriver'];
            }
        }
        return self::$defaultDbDriver;
    }

    /**
     * Busca en la definicion de la base de datos (database.php)
     * si se ha definido una default , de ser asi retorna su
     * identificador.
     *
     * @return string el driver default o null
     */
    public static function getDefaultDatabase() {
        if (!isset(self::$defaultDb)) {
            require (APPPATH . '/config/database.php');
            // Si se ha definido el active_group
            // o base de datos default y asi mismo se ha definido que driver usas la misma , se
            // retorna su valor , de lo contrario null
            if (isset($active_group) and empty($active_group) == FALSE and
                    isset($db[$active_group]['dbdriver'])) {
                self::$defaultDb = $active_group;
            }
        }
        return self::$defaultDb;
    }

    public static function array_ut8_encode_recursive(&$itm) {
        $new = $itm;
        if (is_string($new))
            return utf8_encode($new);
        if (is_array($new))
            return array_map('TSLUtilsHelper::array_ut8_encode_recursive', $new);
        if (is_object($new))
            foreach (get_object_vars($new) as $key => $value)
                $new->$key = array_ut8_encode_recursive($new->$key);
        return $new;
    }

    /**
     * Esta funcion sanitiza la salida desde  la variable del servidor PHP_SELF server .
     * @param string $url la URL a sanitizar
     * @return El url limpio.
     */
    function esc_url($url) {

        if ('' == $url) {
            return $url;
        }

        $url = preg_replace('|[^a-z0-9-~+_.?#=!&;,/:%@$\|*\'()\\x80-\\xff]|i', '', $url);

        $strip = array('%0d', '%0a', '%0D', '%0A');
        $url = (string) $url;

        $count = 1;
        while ($count) {
            $url = str_replace($strip, '', $url, $count);
        }

        $url = str_replace(';//', '://', $url);

        $url = htmlentities($url);

        $url = str_replace('&amp;', '&#038;', $url);
        $url = str_replace("'", '&#039;', $url);

        if ($url[0] !== '/') {
            // We're only interested in relative links from $_SERVER['PHP_SELF']
            return '';
        } else {
            return $url;
        }
    }

}

?>