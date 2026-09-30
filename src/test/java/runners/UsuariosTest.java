package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Runs every feature under classpath:usuarios in parallel.
 * Tags and features can be filtered with -Dkarate.options="--tags @smoke".
 * Number of threads: -Dthreads=5 (default).
 */
class UsuariosTest {

    @Test
    void ejecutarSuiteUsuarios() {
        int threads = Integer.parseInt(System.getProperty("threads", "5"));
        Results results = Runner.path("classpath:usuarios")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(threads);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
