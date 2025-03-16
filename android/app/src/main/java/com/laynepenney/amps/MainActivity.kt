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
import androidx.compose.ui.unit.dp
import com.amplifyframework.api.graphql.model.ModelMutation
import com.amplifyframework.api.graphql.model.ModelQuery
import com.amplifyframework.api.graphql.model.ModelSubscription
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
                Scaffold(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 24.dp, vertical = 16.dp)
                ) { innerPadding ->
                    Authenticator { state ->
                        Column(
                            modifier = Modifier.padding(innerPadding)
                        ) {
                            Text(
                                modifier = Modifier.padding(vertical = 8.dp),
                                text = "Hello ${state.user.username}!",
                            )

                            Button(
                                modifier = Modifier.padding(vertical = 8.dp),
                                onClick = {
                                    // TODO: show field to enter content

                                    val todo = Todo.builder()
                                        .isDone(false)
                                        .content("My first todo")
                                        .build()

                                    val create = ModelMutation.create(todo)
                                    Amplify.API.mutate(create, { response ->
                                        Log.i(
                                            "MyAmplifyApp",
                                            "Added Todo with id: ${response.data.id}"
                                        )
                                    }, { error ->
                                        Log.e("MyAmplifyApp", "Create failed", error)
                                    })
                                }) {
                                Text(text = "Create Todo")
                            }
                            TodoList(
                                rowModifier = Modifier.padding(vertical = 8.dp)
                            )
                            Button(
                                modifier = Modifier.padding(vertical = 8.dp),
                                onClick = {
                                    Amplify.Auth.signOut { }
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
fun TodoList(listModifier: Modifier = Modifier, rowModifier: Modifier = Modifier) {
    var todoList by remember { mutableStateOf(emptyList<Todo>()) }

    LaunchedEffect(Unit) {
        // API request to list all Todos
        val query = ModelQuery.list(Todo::class.java)
        Amplify.API.query(query, { list ->
            todoList = list.data.items.toList()
        }, { error ->
            Log.e("MyAmplifyApp", "Failed to query.", error)
        })

        val onCreate = ModelSubscription.onCreate(Todo::class.java)
        Amplify.API.subscribe(onCreate, { subscription ->
            Log.i("ApiQuickStart", "Subscription established $subscription")
        }, { response ->
            Log.i("ApiQuickStart", "Todo create subscription received: ${response.data}")
            todoList = todoList + response.data
        }, { error ->
            Log.e("ApiQuickStart", "Subscription failed", error)
        }, {
            Log.i("ApiQuickStart", "Subscription completed")
        })
    }

    LazyColumn(listModifier) {
        items(todoList) { todo ->
            Row(rowModifier) {
                // TODO: add toggle
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