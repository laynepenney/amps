package com.laynepenney.amps

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.amplifyframework.api.graphql.model.ModelMutation
import com.amplifyframework.api.graphql.model.ModelQuery
import com.amplifyframework.core.Amplify
import com.amplifyframework.datastore.generated.model.Todo
import com.amplifyframework.ui.authenticator.ui.Authenticator
import com.laynepenney.amps.ui.theme.AmpsTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        enableEdgeToEdge()
        setContent {
            AmpsTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Authenticator { state ->
                        Column {
                            Text(
                                text = "Hello ${state.user.username}!",
                            )

                            Button(onClick = {
                                val todo = Todo.builder()
                                    .isDone(false)
                                    .content("My first todo")
                                    .build()

                                Amplify.API.mutate(
                                    ModelMutation.create(todo),
                                    { Log.i("MyAmplifyApp", "Added Todo with id: ${it.data.id}")},
                                    { Log.e("MyAmplifyApp", "Create failed", it)},
                                )
                            }) {
                                Text(text = "Create Todo")
                            }
                            TodoList()
                            Button(onClick = {
                                Amplify.Auth.signOut {  }
                            }) {
                                Text(text = "Sign Out")
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun TodoList() {
    var todoList by remember { mutableStateOf(emptyList<Todo>()) }

    LaunchedEffect(Unit) {
        // API request to list all Todos
        Amplify.API.query(
            ModelQuery.list(Todo::class.java),
            { todoList = it.data.items.toList() },
            { Log.e("MyAmplifyApp", "Failed to query.", it) }
        )
    }

    LazyColumn {
        items(todoList) { todo ->
            Row {
                // Render your activity item here
                Text(text = todo.content)
            }
        }
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    AmpsTheme {
        Greeting("Android")
    }
}